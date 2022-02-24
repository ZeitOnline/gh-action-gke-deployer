#!/bin/sh
set -e

command="$(basename -- $0)"
creds_dir=$(mktemp -d --tmpdir=/dev/shm)

# Write credentials to a location outside the Drone workspace to
# avoid collisions when steps run in parallel
export kubeconfig="${creds_dir}/.kube/config"
export cloudsdk_config="${creds_dir}/gcloud/"

case $command in
  # List of commands that need Kubernetes authentication
  kubectl|kubecfg|linkerd) cmd_needs_kube_auth=true;;
  # List of commands that need GCP authentication
  gcloud|gsutil) cmd_needs_gcp_auth=true;;
esac

if [ "$cmd_needs_kube_auth" = true -o "$cmd_needs_gcp_auth" = true ] && [ ! -e $cloudsdk_config ]; then

  [ -z "$INPUT_ZONE" ]            && echo "Missing action input 'zone'" && exit 1;
  [ -z "$INPUT_PROJECT" ]         && echo "Missing action input 'project'" && exit 1;
  [ -z "$INPUT_CLUSTER" ]         && echo "Missing action input 'cluster'" && exit 1;
  [ -z "$INPUT_GCP_CREDENTIALS" ] && echo "Missing action input 'gcp_credentials'" && exit 1;

  echo "Activating GCP service account..."

  # Use standalone 'echo' to be able to suppress backslash-escape interpretation
  /bin/echo -E ${INPUT_GCP_CREDENTIALS} > ${creds_dir}/credentials.json
  
  /usr/bin/gcloud.original auth activate-service-account --key-file=${creds_dir}/credentials.json
fi

if [ "$cmd_needs_kube_auth" = true ] && [ ! -e $kubeconfig ]; then

  echo "Writing k8s credentials to ${kubeconfig}..."

  /usr/bin/gcloud.original container clusters get-credentials ${INPUT_CLUSTER} --project=${INPUT_PROJECT} --zone=${INPUT_ZONE}

  if [ -n "$INPUT_NAMESPACE" ]; then
    echo "Setting namespace of k8s context to '${INPUT_NAMESPACE}'..."

    kubectl.original config set-context --current --namespace=${INPUT_NAMESPACE}
  fi
fi

# ArgoCD Token Environment variable
if [ "$command" = "argocd" ]; then
  [ -z "$INPUT_ARGOCD_TOKEN" ]  && echo "Missing action input'argocd_token'" && exit 1;
  [ -z "$INPUT_ARGOCD_SERVER" ] && echo "Missing action input 'argocd_server'" && exit 1;
  
  export ARGOCD_AUTH_TOKEN="${INPUT_ARGOCD_TOKEN}"
  export ARGOCD_SERVER="${INPUT_ARGOCD_SERVER}"
fi

exec $0.original "$@"
