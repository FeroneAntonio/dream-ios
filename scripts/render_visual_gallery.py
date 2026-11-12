"""Build the native macOS gallery using the app's production geometry/rasterizer."""
import argparse
import platform
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--atlas', action='store_true', help='Export the 432-study creative atlas')
args = parser.parse_args()
# Shared production artwork only; Foundation Models is an optional iOS adapter.
sources = sorted(path for path in (root / 'Sources/Artwork').rglob('*.swift')
                 if not path.name.startswith('NarrativeModel'))
sources.append(root / 'Sources/Integrations/Dreamy/DreamEmotion.swift')
with tempfile.TemporaryDirectory(prefix='dream-gallery-') as folder:
    executable=Path(folder)/'gallery'
    subprocess.run(['xcrun','swiftc','-O','-target',platform.machine()+'-apple-macos15.0','-swift-version','6','-module-cache-path',folder+'/modules',
        *map(str, sources),str(root/'Tools'/('ArtAtlas.swift' if args.atlas else 'VisualGallery.swift')),'-o',str(executable)],check=True)
    subprocess.run([str(executable),str(root/'Fixtures'/('creative_atlas.json' if args.atlas else 'fictional_dreams.json')),str(args.output.resolve())],check=True)
