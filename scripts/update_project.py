"""Add Swift source/test files and generated Core ML resources to the small Xcode project."""
from pathlib import Path
import hashlib
import re

root = Path(__file__).resolve().parents[1]
project = root/'DREAM.xcodeproj/project.pbxproj'
text = project.read_text()

def identifier(value):
    return hashlib.sha256(value.encode()).hexdigest()[:24].upper()

def append_object(body):
    global text
    text = text.replace('objects = {\n', 'objects = {\n'+body+'\n', 1)

def add_file(path, kind, phase):
    global text
    if f'path = {path};' in text:
        return
    reference, build = identifier(path), identifier('build:'+path)
    append_object(f'{reference} = {{isa = PBXFileReference; lastKnownFileType = {kind}; path = {path}; sourceTree = "<group>";}};')
    append_object(f'{build} = {{isa = PBXBuildFile; fileRef = {reference};}};')
    group = '000000000000000000000002'
    text = re.sub(r'('+group+r' = \{isa = PBXGroup; children = \()', lambda m: m[1]+reference+',', text, count=1)
    text = re.sub(r'('+phase+r' = \{isa = PBX\w+BuildPhase; buildActionMask = 2147483647; files = \()', lambda m: m[1]+build+',', text,count=1)

for path in sorted((root/'Sources').glob('*.swift')):
    add_file(str(path.relative_to(root)), 'sourcecode.swift', '000000000000000000000006')
for path in sorted((root/'Tests').glob('*.swift')):
    add_file(str(path.relative_to(root)), 'sourcecode.swift', '000000000000000000000BBA')
for path in sorted((root/'UITests').glob('*.swift')):
    add_file(str(path.relative_to(root)), 'sourcecode.swift', '000000000000000000000FA2')
for name,kind in [('DreamyEmotion.mlpackage','folder.mlpackage'),('dreamy-vocab.txt','text'),('dreamy-test-vectors.json','text.json'),('ThirdPartyNotices.txt','text')]:
    if (root/'Models'/name).exists():
        add_file('Models/'+name,kind,'000000000000000000000008')
project.write_text(text)

# Small synthetic fixtures are used by DEBUG probes and regression tests only.
add_file('Fixtures/fictional_dreams.json','text.json','000000000000000000000008')
project.write_text(text)

add_file('Fixtures/visual-recipe-v1.json','text.json','000000000000000000000008')
project.write_text(text)
