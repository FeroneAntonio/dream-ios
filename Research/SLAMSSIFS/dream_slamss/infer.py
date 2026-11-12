"""Research-only CPU inference. No training, invented features, or bundled weights."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import numpy as np
from scipy.io import loadmat
import torch
from .vendor.SLAMSS_IFS_Model import Attention, Encoder, Decoder, CNN, Seq2Seq

COMMIT = '088e363873b4ac5b27bc23fb038abc052889698c'
PREPROCESSING = 'upstream-prepared-mat-v1'
STAGES = ['awake', 'light', 'deep', 'rem']


def prepared_features(path):
    # Do not load any ground-truth stage field: upstream evaluation seeds its
    # decoder with the first true label, which is unavailable during inference.
    data = loadmat(path, variable_names=['hr','act','hz','clock','time','hr2'])
    def vector(name):
        value = np.asarray(data[name], dtype=np.float64).reshape(-1)
        if not np.isfinite(value).all():
            raise ValueError(f'{name}: non-finite feature')
        return value
    hz, clock, time = [vector(name) for name in ['hz','clock','time']]
    epochs = len(hz)
    if not 1 <= epochs <= 1200 or len(clock) != epochs or len(time) != epochs:
        raise ValueError('Expected 1..1200 synchronized 30-second epochs')
    hr, act = vector('hr') / 60.0, vector('act')
    if len(hr) != epochs*30 or len(act) != epochs*30:
        raise ValueError('Expected one IHR/actigraphy sample per second, synchronized to epochs')
    if hr.std() == 0 or act.std() == 0:
        raise ValueError('A constant signal cannot be z-normalized')
    hr2 = np.asarray(data['hr2'], dtype=np.float64)
    if hr2.shape != (2, epochs) or not np.isfinite(hr2).all():
        raise ValueError('Expected hr2 with shape (2, epochs)')
    signals = np.stack([(hr-hr.mean())/hr.std(), (act-act.mean())/act.std()], axis=1)
    features = np.stack([hz, clock, time, hr2[0]/60, hr2[1]/60], axis=1)
    # The published testing notebook accidentally takes 3 channels. CNN requires 5.
    return torch.tensor(signals[None], dtype=torch.float32), torch.tensor(features[None], dtype=torch.float32)


def architecture():
    attention = Attention(96, 96)
    encoder = Encoder(2, 2, 96, 96, 0)
    decoder = Decoder(4, 4, 96, 96, 0, attention)
    return CNN().eval(), Seq2Seq(encoder, decoder, device='cpu').eval()


def verify_manifest(path):
    manifest = json.loads(path.read_text())
    if manifest.get('upstream_commit') != COMMIT or manifest.get('preprocessing') != PREPROCESSING:
        raise ValueError('Wrong architecture/preprocessing provenance')
    if manifest.get('trained') is not True or manifest.get('synthetic') is not False:
        raise ValueError('Only genuine, trained checkpoints may produce a research report')
    source = manifest.get('weights_source', '')
    if not source.startswith('https://') or not manifest.get('training_provenance', '').strip():
        raise ValueError('Weights source and training provenance are required')
    for name in ['cnn','sequence']:
        item = manifest[name]
        checkpoint = (path.parent/item['file']).resolve()
        actual = hashlib.file_digest(checkpoint.open('rb'), 'sha256').hexdigest()
        if actual != item['sha256']:
            raise ValueError(f'{name}: checkpoint hash mismatch')
    return manifest


def load_checkpoint(module, path):
    # No arbitrary pickle execution and no non-strict loading of random layers.
    state = torch.load(path, map_location='cpu', weights_only=True)
    if not isinstance(state, dict) or not all(isinstance(v, torch.Tensor) for v in state.values()):
        raise ValueError('Expected a tensor state_dict')
    state = {k.removeprefix('module.'): v for k,v in state.items()}
    module.load_state_dict(state, strict=True)


def predict(cnn, sequence, signals, features, initial_stage):
    target = torch.zeros(1, features.shape[1], 4)
    target[0,0,STAGES.index(initial_stage)] = 1
    with torch.inference_mode():
        logits = sequence(cnn(signals, features), signals, target, teacher_forcing_ratio=0)
        scores = torch.softmax(logits, dim=-1)[0]
    if not torch.isfinite(scores).all():
        raise ValueError('Model produced non-finite scores')
    return scores.tolist()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--features', type=Path, required=True)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--start', required=True, help='Actual UTC start, ISO8601 with Z, whole seconds')
    parser.add_argument('--initial-stage', choices=STAGES, required=True)
    parser.add_argument('--initial-stage-basis', required=True, help='Explicit known/assumed basis; never a hidden ground-truth label')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    start = datetime.strptime(args.start, '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=timezone.utc)
    if not args.initial_stage_basis.strip():
        parser.error('An initial-stage basis is required')
    manifest = verify_manifest(args.manifest)
    signals, features = prepared_features(args.features)
    cnn, sequence = architecture()
    for role, module in [('cnn',cnn),('sequence',sequence)]:
        load_checkpoint(module, args.manifest.parent/manifest[role]['file'])
    scores = predict(cnn,sequence,signals,features,args.initial_stage)
    model = dict(name='SLAMSS-IFS',upstream_commit=COMMIT,preprocessing=PREPROCESSING,
        cnn_sha256=manifest['cnn']['sha256'],sequence_sha256=manifest['sequence']['sha256'],
        weights_source=manifest['weights_source'], initial_stage=args.initial_stage,
        initial_stage_basis=args.initial_stage_basis, validation='research-unvalidated-in-DREAM',synthetic=False)
    report = dict(schema_version=1,recording_start=start.strftime('%Y-%m-%dT%H:%M:%SZ'),epoch_seconds=30,probabilities=scores,model=model)
    # Exclusive creation avoids accidentally overwriting an existing research report.
    with args.output.open('x') as output:
        json.dump(report,output,allow_nan=False)
        output.write('\n')

if __name__ == '__main__':
    main()
