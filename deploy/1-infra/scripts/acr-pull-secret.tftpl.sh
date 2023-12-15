kubectl create secret docker-registry ${acr_pull_secret_name} \
  --namespace ${aio_cluster_namespace} \
  --docker-server=${acr_name}.azurecr.io \
  --docker-username=${acr_pull_sp_client_id} \
  --docker-password=${acr_pull_sp_client_secret} \
  --dry-run=client -o yaml | kubectl apply -f -
