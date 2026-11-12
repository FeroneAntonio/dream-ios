import json
from pathlib import Path
import tempfile
import unittest
import numpy as np
from scipy.io import savemat
import torch
from dream_slamss.infer import prepared_features, architecture, predict, verify_manifest

class ResearchAdapterTests(unittest.TestCase):
    def test_features_keep_five_channels_and_ignore_ground_truth(self):
        with tempfile.TemporaryDirectory() as folder:
            path=Path(folder)/'synthetic.mat'
            data=dict(hr=np.arange(120)+60,act=np.arange(120)**2,hz=np.arange(4),clock=np.arange(4),time=np.arange(4),hr2=np.ones((2,4))*60,stg_cor_cln=['DO NOT READ LABELS'])
            savemat(path,data)
            signals, features=prepared_features(path)
            self.assertEqual(tuple(signals.shape),(1,120,2))
            self.assertEqual(tuple(features.shape),(1,4,5))
            self.assertAlmostEqual(float(signals.mean()),0,places=6)
            np.testing.assert_array_equal(features[0,:,3:],np.ones((4,2)))
            data['act']=np.ones(120)
            savemat(path,data)
            with self.assertRaises(ValueError): prepared_features(path)

    def test_random_weights_architecture_smoke_only_never_exports_a_report(self):
        torch.set_num_threads(2)
        torch.manual_seed(123)
        cnn, sequence=architecture()
        signals=torch.randn(1,120,2)
        features=torch.randn(1,4,5)
        scores=np.array(predict(cnn,sequence,signals,features,'awake'))
        self.assertEqual(scores.shape,(4,4))
        np.testing.assert_allclose(scores.sum(1),np.ones(4),rtol=1e-6)
        self.assertTrue(np.isfinite(scores).all())

    def test_template_cannot_be_used_as_trained_weights(self):
        path=Path(__file__).parents[1]/'checkpoints.example.json'
        with self.assertRaises(ValueError): verify_manifest(path)

if __name__=='__main__': unittest.main()
