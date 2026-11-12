"""Install the pinned Core ML release package before building (Python standard library)."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import urllib.request
import zipfile

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root/'Research/DReAMy/artifact.json').read_text())
with tempfile.TemporaryDirectory(prefix='dreamy-model-') as folder:
    folder = Path(folder)
    archive = folder/'model.zip'
    print('Downloading verified DReAMy model (about 200 MB)…',flush=True)
    urllib.request.urlretrieve(manifest['url'],archive)
    with archive.open('rb') as stream:
        digest = hashlib.sha256()
        for chunk in iter(lambda: stream.read(1024*1024), b''): digest.update(chunk)
        actual = digest.hexdigest()
    if actual != manifest['sha256'] or archive.stat().st_size != manifest['bytes']:
        raise ValueError('Model archive integrity check failed')
    unpack = folder/'unpacked'
    with zipfile.ZipFile(archive) as z:
        for info in z.infolist():
            dest = (unpack/info.filename).resolve()
            if not dest.is_relative_to(unpack.resolve()):
                raise ValueError('Unsafe archive member')
        z.extractall(unpack)
    package=unpack/'DreamyEmotion.mlpackage'
    if not (package/'Manifest.json').is_file():
        raise ValueError('Missing model package')
    target=root/'Models/DreamyEmotion.mlpackage'
    if target.exists(): shutil.rmtree(target)
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.move(package,target)
subprocess.run(['python3',str(root/'scripts/update_project.py')],check=True)
print('DReAMy installed. Open DREAM.xcodeproj to build.')
