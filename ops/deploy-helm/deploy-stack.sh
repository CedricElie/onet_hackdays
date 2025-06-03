# Add helm repos
helm repo add impress https://suitenumerique.github.io/docs/
helm repo add meet https://suitenumerique.github.io/meet/
helm repo add livekit https://helm.livekit.io
helm repo update

# Install impress in ns impress
helm install -n impress keycloak oci://registry-1.docker.io/bitnamicharts/keycloak -f ./keycloak.values.yaml;
helm install -n impress redis oci://registry-1.docker.io/bitnamicharts/redis -f ./impress-redis.values.yaml;
helm install -n impress postgresql oci://registry-1.docker.io/bitnamicharts/postgresql -f ./impress-postgresql.values.yaml;
helm install -n impress minio oci://registry-1.docker.io/bitnamicharts/minio -f ./minio.values.yaml;
helm install -n impress impress impress/docs -f ./impress.values.yaml;

# Install meet in ns meet
helm install redis oci://registry-1.docker.io/bitnamicharts/redis -f ./meet-redis.values.yaml -n meet
helm install postgresql oci://registry-1.docker.io/bitnamicharts/postgresql -f ./meet-postgresql.values.yaml -n meet
helm install livekit livekit/livekit-server -f ./livekit.values.yaml -n meet
helm install meet meet/meet -f ./meet.values.yaml -n meet
