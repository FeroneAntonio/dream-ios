"""Convert pinned, genuine DReAMy weights. Run on macOS; never trains a replacement."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import types
import urllib.request

REPO = 'DReAMy-lib/bert-base-cased-DreamBank-emotion-presence'
REVISION = '302196dad5648c1a28d70de3055373ef11975f04'
SOURCE_SHA256 = 'd6ada0805add6533d620634cf1c3ab6fc98d27f9c3b7e03e4004f51dcddf7fe5'


def main():
    import coremltools as ct
    import numpy as np
    import torch
    from transformers import AutoModelForSequenceClassification, AutoTokenizer

    parser = argparse.ArgumentParser()
    parser.add_argument('--cache', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.cache.mkdir(parents=True, exist_ok=True)
    args.output.mkdir(parents=True, exist_ok=True)
    for filename in ['config.json', 'tokenizer_config.json', 'special_tokens_map.json', 'vocab.txt', 'model.safetensors', 'README.md']:
        dest = args.cache / filename
        if not dest.exists():
            print(f'Downloading {filename}', flush=True)
            urllib.request.urlretrieve(f'https://huggingface.co/{REPO}/resolve/{REVISION}/{filename}', dest)
    assert hashlib.sha256((args.cache / 'model.safetensors').read_bytes()).hexdigest() == SOURCE_SHA256
    torch.set_num_threads(4)
    tokenizer = AutoTokenizer.from_pretrained(args.cache, local_files_only=True)
    model = AutoModelForSequenceClassification.from_pretrained(args.cache, local_files_only=True, attn_implementation='eager').eval()
    assert [model.config.id2label[i] for i in range(5)] == ['AN', 'AP', 'SD', 'CO', 'HA']
    # Float32's minimum mask value overflows FP16 and can produce NaNs.
    # -10000 also masks softmax completely, but is representable in FP16.
    # Reference predictions below use the original unmodified PyTorch model.
    reference = AutoModelForSequenceClassification.from_pretrained(args.cache, local_files_only=True, attn_implementation='eager').eval()
    def finite_mask(self, attention_mask, input_shape, device=None, dtype=None):
        return (1.0 - attention_mask[:, None, None, :].to(dtype=self.dtype)) * -10000.0
    model.bert.get_extended_attention_mask = types.MethodType(finite_mask, model.bert)

    class Logits(torch.nn.Module):
        def __init__(self, bert):
            super().__init__()
            self.bert = bert
        def forward(self, input_ids, attention_mask, token_type_ids):
            return self.bert(input_ids=input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids).logits

    reports = [
        'I was lost in a maze. I felt confused and could not find my way home.',
        'I was laughing with my friends in a beautiful garden. I felt happy.',
        'A stranger chased me through a dark street. I was terrified.',
        'I woke up crying because my friend had gone away.',
        'I was angry and shouted at everyone in the room.',
        'I looked at a table and a window.'
    ]
    tokens = tokenizer(reports[0], return_tensors='pt', padding='max_length', truncation=True, max_length=512)
    inputs = tuple(tokens[key].to(torch.int32) for key in ['input_ids', 'attention_mask', 'token_type_ids'])
    wrapper = Logits(model)
    with torch.inference_mode():
        traced = torch.jit.trace(wrapper, inputs, strict=True)
    converted = ct.convert(traced, convert_to='mlprogram', minimum_deployment_target=ct.target.iOS18,
        inputs=[ct.TensorType(name=key, shape=(1, 512), dtype=np.int32) for key in ['input_ids','attention_mask','token_type_ids']],
        outputs=[ct.TensorType(name='logits', dtype=np.float32)], compute_precision=ct.precision.FLOAT16,
        compute_units=ct.ComputeUnit.CPU_ONLY)
    converted.author = 'DReAMy authors; Core ML conversion by DREAM'
    converted.license = 'Apache-2.0'
    converted.short_description = 'English DreamBank emotion presence: AN AP SD CO HA; independent sigmoid logits.'
    converted.user_defined_metadata['huggingface_revision'] = REVISION
    converted.save(str(args.output / 'DreamyEmotion.mlpackage'))
    shutil.copy(args.cache / 'vocab.txt', args.output / 'dreamy-vocab.txt')
    verification = []
    for report in reports:
        tokens = tokenizer(report, return_tensors='pt', padding='max_length', truncation=True, max_length=512)
        inputs = tuple(tokens[k].to(torch.int32) for k in ['input_ids','attention_mask','token_type_ids'])
        with torch.inference_mode():
            expected = reference(**tokens).logits.numpy()[0]
        actual = converted.predict({k: tokens[k].numpy().astype(np.int32) for k in tokens})['logits'][0]
        assert np.isfinite(actual).all(), 'Non-finite Core ML outputs'
        error = float(np.max(np.abs(expected-actual)))
        assert error < 0.08, (report, error)
        expected_scores = 1/(1+np.exp(-expected))
        actual_scores = 1/(1+np.exp(-actual))
        assert np.array_equal(expected_scores > 0.5, actual_scores > 0.5)
        verification.append(dict(text=report, token_ids=inputs[0].tolist()[0], scores=actual_scores.tolist(), max_logit_error=error))
        print(report, actual_scores, 'error', error, flush=True)
    manifest = dict(model=REPO, revision=REVISION, source_sha256=hashlib.sha256((args.cache/'model.safetensors').read_bytes()).hexdigest(),
                    labels=['AN','AP','SD','CO','HA'], token_limit=512, precision='float16', license='Apache-2.0', fixtures=verification)
    (args.output / 'dreamy-verification.json').write_text(json.dumps(manifest, indent=2)+'\n')
    edges = ["Café déjà vu — I'm running!", "Hello [MASK] world [CLS]", "你好, Dream 🌙", "I\u0000walk\tthrough\nrooms.", "a"*101, "dream "*600, "naïve\u0301 eyes… why?"]
    for text in edges:
        ids = tokenizer(text, padding='max_length', truncation=True, max_length=512)['input_ids']
        verification.append(dict(text=text, token_ids=ids))
    (args.output / 'dreamy-test-vectors.json').write_text(json.dumps(dict(fixtures=verification), indent=2)+'\n')
    print('Verified genuine converted model', flush=True)

if __name__ == '__main__':
    main()
