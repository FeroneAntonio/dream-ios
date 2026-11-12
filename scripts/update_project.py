"""Synchronize Xcode groups with the source folders, retaining target/signing settings."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'DREAM.xcodeproj/project.pbxproj'
SOURCE_PHASES = {
    'Sources': '000000000000000000000006',
    'Tests': '000000000000000000000BBA',
    'UITests': '000000000000000000000FA2',
}
RESOURCE_PHASE = '000000000000000000000008'


def identifier(value):
    return hashlib.sha256(value.encode()).hexdigest()[:24].upper()


def openstep(value, depth=0):
    """Encode the small plist value set used by Xcode project files."""
    indent = '\t' * depth
    if isinstance(value, dict):
        items = [f'{indent}\t{json.dumps(key)} = {openstep(item, depth + 1)};'
                 for key, item in sorted(value.items())]
        return '{\n' + '\n'.join(items) + '\n' + indent + '}'
    if isinstance(value, list):
        items = [indent + '\t' + openstep(item, depth + 1) + ',' for item in value]
        return '(\n' + '\n'.join(items) + '\n' + indent + ')'
    if isinstance(value, (str, int)):
        return json.dumps(value, ensure_ascii=False)
    raise TypeError(f'Unsupported project value: {type(value)}')


def main():
    project = json.loads(subprocess.check_output(
        ['plutil', '-convert', 'json', '-o', '-', str(PROJECT)]))
    objects = project['objects']
    main_group = objects[project['rootObject']]['mainGroup']
    managed_roots = (*SOURCE_PHASES, 'Models', 'Fixtures')
    # Rebuild only managed file/group references, never targets or build settings.
    removed = {key for key, item in objects.items()
               if item['isa'] == 'PBXFileReference'
               and item.get('path', '').split('/')[0] in managed_roots}
    removed.update(key for key, item in objects.items()
                   if item['isa'] == 'PBXGroup'
                   and item.get('sourceTree') == 'SOURCE_ROOT'
                   and item.get('path', '').split('/')[0] in managed_roots)
    pending = list(removed)
    while pending:
        for child in objects[pending.pop()].get('children', []):
            if child not in removed:
                removed.add(child)
                pending.append(child)
    removed.update(key for key, item in objects.items()
                   if item['isa'] == 'PBXBuildFile' and item.get('fileRef') in removed)
    for key in removed:
        objects.pop(key)
    for item in objects.values():
        for field in ('children', 'files'):
            if field in item:
                item[field] = [key for key in item[field] if key not in removed]

    def group(path):
        if path == Path('.'):
            return main_group
        key = identifier('group:' + path.as_posix())
        if key not in objects:
            parent = group(path.parent)
            objects[key] = {'isa': 'PBXGroup', 'children': [], 'name': path.name,
                            'path': path.as_posix(), 'sourceTree': 'SOURCE_ROOT'}
            objects[parent]['children'].append(key)
        return key

    def add_file(path, kind, phase):
        relative = path.relative_to(ROOT)
        reference = identifier('file:' + relative.as_posix())
        build = identifier('build:' + relative.as_posix())
        objects[reference] = {'isa': 'PBXFileReference', 'lastKnownFileType': kind,
                              'path': path.name, 'sourceTree': '<group>'}
        objects[build] = {'isa': 'PBXBuildFile', 'fileRef': reference}
        objects[group(relative.parent)]['children'].append(reference)
        objects[phase]['files'].append(build)

    for folder, phase in SOURCE_PHASES.items():
        for path in sorted((ROOT / folder).rglob('*.swift')):
            add_file(path, 'sourcecode.swift', phase)
    for name, kind in [('DreamyEmotion.mlpackage', 'folder.mlpackage'),
                       ('dreamy-vocab.txt', 'text'), ('dreamy-test-vectors.json', 'text.json'),
                       ('ThirdPartyNotices.txt', 'text')]:
        path = ROOT / 'Models' / name
        if path.exists():
            add_file(path, kind, RESOURCE_PHASE)
    for path in sorted((ROOT / 'Fixtures').glob('*.json')):
        add_file(path, 'text.json', RESOURCE_PHASE)
    for item in objects.values():
        if item['isa'] == 'PBXGroup':
            item['children'].sort(key=lambda key: (
                objects[key]['isa'] != 'PBXGroup',
                objects[key].get('name', objects[key].get('path', '')).lower()))
    PROJECT.write_text('// !$*UTF8*$!\n' + openstep(project) + '\n')
    subprocess.run(['plutil', '-lint', str(PROJECT)], check=True)


if __name__ == '__main__':
    main()
