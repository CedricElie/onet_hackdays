operator-sdk init --domain onet.bigtree.space --plugins helm

operator-sdk create api --group app --version v1alpha1 --kind Impress --helm-chart ../helm/impress

operator-sdk create api --group app --version v1alpha1 --kind Meet --helm-chart ../helm/meet