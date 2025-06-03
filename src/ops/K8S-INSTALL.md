kubectl create clusterrolebinding cluster-admin-binding   --clusterrole cluster-admin   --user $(gcloud config get-value account)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.2/deploy/static/provider/cloud/deploy.yaml

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.2/deploy/static/provider/cloud/deploy.yaml

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.2/cert-manager.yaml

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm update ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.allowSnippetAnnotations=true --set controller.admissionWebhooks.enabled=false