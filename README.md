# GKE Deployer Github Action

Simple shell-based Github Action with kubectl and a configurable set of additional cloud-tools like kustomize and jsonnet.

Authentication for Google Cloud and Kubernetes has to be done seperately. One way is to use the official google actions [`google-github-actions/auth`](https://github.com/google-github-actions/auth) and [`google-github-actions/get-gke-credentials`](https://github.com/google-github-actions/get-gke-credentials).


## Customization

The plugin tools are installed and versioned in `./Dockerfile`.

## Inputs

For ArgoCD `argocd_server` and `argocd_token` must be supplied.

#### `command`

The command to execute.

#### `argocd_token`

The token for ArgoCD authentication.

#### `argocd_server`

The address of the ArgoCD server.


## Example Usage


```yaml
env:
  GCP_PROJECT: 'my-project'
  GKE_ZONE: 'europe-west3-a'
  GKE_CLUSTER: 'my-cluster'
  ARGOCD_SERVER: 'https://argo.mycomapany.com'

steps:
  # Authenticate in GCP
  - uses: 'google-github-actions/auth@v0.6.0'
    with:
      credentials_json: '${{ secret.GCP_CREDENTIALS }}'

  # Get the GKE credentials and write them to KUBECONFIG
  - uses: google-github-actions/get-gke-credentials@v0.6.0
    with:
      project_id: ${{ env.GCP_PROJECT }}
      location: ${{ env.GKE_ZONE }}
      cluster_name: ${{ env.GKE_CLUSTER }}

  - uses: ZeitOnline/gh-action-gke-deployer@v0
    with:
      argocd_server: ${{ env.ARGOCD_SERVER }}
      argocd_token: ${{ secret.ARGOCD_TOKEN }}
      command: |
        kubectl get deployments
        kubectl get pods
```
