helm install keycloak oci://registry-1.docker.io/bitnamicharts/keycloak -f examples/keycloak.values.yaml;
helm install redis oci://registry-1.docker.io/bitnamicharts/redis -f examples/redis.values.yaml;
helm install postgresql oci://registry-1.docker.io/bitnamicharts/postgresql -f examples/postgresql.values.yaml;
helm install minio oci://registry-1.docker.io/bitnamicharts/minio -f examples/minio.values.yaml;
helm repo add impress https://suitenumerique.github.io/docs/;
helm repo update;
helm install impress impress/docs -f examples/impress.values.yaml;
