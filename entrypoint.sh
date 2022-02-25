#!/bin/sh

set -e
set -o pipefail


# whole command gets passed as string. we assume the part before the first space
# ist the command itself, the rest are arguments
command="${1%% *}"

# ArgoCD Token Environment variable
if [ "$command" = "argocd" ]; then
  [ -z "$INPUT_ARGOCD_TOKEN" ]  && echo "Missing action input'argocd_token'" && exit 1;
  [ -z "$INPUT_ARGOCD_SERVER" ] && echo "Missing action input 'argocd_server'" && exit 1;

  export ARGOCD_AUTH_TOKEN="${INPUT_ARGOCD_TOKEN}"
  export ARGOCD_SERVER="${INPUT_ARGOCD_SERVER}"
fi

# exec "$1"
/bin/sh -c "set -e;  set -o pipefail; $1"
