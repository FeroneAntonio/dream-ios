---
license: apache-2.0
tags:
- generated_from_trainer
metrics:
- f1
- accuracy
model-index:
- name: bert-base-cased-DreamBank
  results: []
widget:
- text: >-
    I dreamed that Hannah and Sue and I travelled back in time to meet her
    parents. Weird.
pipeline_tag: text-classification
---

<!-- This model card has been generated automatically according to the information the Trainer had access to. You
should probably proofread and complete it, then remove this comment. -->

# bert-base-cased-DreamBank

This model is a fine-tuned version of [bert-base-cased](https://huggingface.co/bert-base-cased) on the None dataset.
It achieves the following results on the evaluation set:
- Loss: 0.2697
- F1: 0.8335
- Roc Auc: 0.8761
- Accuracy: 0.6703

## Model description

More information needed

## Intended uses & limitations

More information needed

## Training and evaluation data

More information needed

## Training procedure

### Training hyperparameters

The following hyperparameters were used during training:
- learning_rate: 1e-05
- train_batch_size: 4
- eval_batch_size: 4
- seed: 42
- optimizer: Adam with betas=(0.9,0.999) and epsilon=1e-08
- lr_scheduler_type: linear
- num_epochs: 10

### Training results

| Training Loss | Epoch | Step | Validation Loss | F1     | Roc Auc | Accuracy |
|:-------------:|:-----:|:----:|:---------------:|:------:|:-------:|:--------:|
| No log        | 1.0   | 185  | 0.5983          | 0.0330 | 0.5064  | 0.0162   |
| No log        | 2.0   | 370  | 0.3939          | 0.6104 | 0.7317  | 0.4649   |
| 0.4638        | 3.0   | 555  | 0.3227          | 0.7572 | 0.8154  | 0.5568   |
| 0.4638        | 4.0   | 740  | 0.2852          | 0.7902 | 0.8412  | 0.5784   |
| 0.4638        | 5.0   | 925  | 0.2720          | 0.7982 | 0.8382  | 0.6270   |
| 0.1877        | 6.0   | 1110 | 0.2795          | 0.8144 | 0.8619  | 0.6541   |
| 0.1877        | 7.0   | 1295 | 0.2575          | 0.8147 | 0.8568  | 0.6541   |
| 0.1877        | 8.0   | 1480 | 0.2556          | 0.8204 | 0.8630  | 0.6595   |
| 0.0952        | 9.0   | 1665 | 0.2668          | 0.8321 | 0.8764  | 0.6703   |
| 0.0952        | 10.0  | 1850 | 0.2697          | 0.8335 | 0.8761  | 0.6703   |


### Framework versions

- Transformers 4.25.1
- Pytorch 1.12.1
- Datasets 2.5.1
- Tokenizers 0.12.1

# Cite
Should you use our models in your work, please consider citing us as:
```bibtex
@article{BERTOLINI2024406,
title = {DReAMy: a library for the automatic analysis and annotation of dream reports with multilingual large language models},
journal = {Sleep Medicine},
volume = {115},
pages = {406-407},
year = {2024},
note = {Abstracts from the 17th World Sleep Congress},
issn = {1389-9457},
doi = {https://doi.org/10.1016/j.sleep.2023.11.1092},
url = {https://www.sciencedirect.com/science/article/pii/S1389945723015186},
author = {L. Bertolini and A. Michalak and J. Weeds}
}
```