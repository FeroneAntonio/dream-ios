"""Build the native macOS gallery using the app's production geometry/rasterizer."""
import argparse
import platform
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
# Explicit list ensures the CLI exercises shared production code, without iOS UI/models.
names = ['VisualFamily','VisualLayout','NormalizedPoint','VisualRGBA','VisualPalette','PaletteRecipe','VisualLayerRole',
 'VisualDirection','VisualLayer','FinishRecipe','MotionRecipe','VisualEvidenceSource','VisualDecision','UserVisualAdjustments',
 'DreamVisualRecipe','SeededRandom','SeededNoise','NarrativeCueKind','NarrativeCue','NarrativeVisualFeatures','NarrativeVisualAnalyzer',
 'VisualRuleEngine','DreamEmotion','RenderPoint','RenderMarkKind','RenderMark','RenderPlan','ProceduralRenderEngine','FamilyGeometry','ProceduralRasterizer','HandDrawnGeometry','HandDrawnRenderer','HandDrawnScenery']
with tempfile.TemporaryDirectory(prefix='dream-gallery-') as folder:
    executable=Path(folder)/'gallery'
    subprocess.run(['xcrun','swiftc','-O','-target',platform.machine()+'-apple-macos15.0','-swift-version','6','-module-cache-path',folder+'/modules',
        *[str(root/'Sources'/(name+'.swift')) for name in names],str(root/'Tools/VisualGallery.swift'),'-o',str(executable)],check=True)
    subprocess.run([str(executable),str(root/'Fixtures/fictional_dreams.json'),str(args.output.resolve())],check=True)
