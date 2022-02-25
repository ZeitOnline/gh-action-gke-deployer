# GKE Deployer Github Action

Simple shell-based Github Action with kubectl and a configurable set of additional cloud-tools like kustomize and jsonnet.
The `gcloud` and `kubectl` commands are wrapped in a small script which generates K8s credentials on their first invocation.


## Customization

The plugin tools are installed and versioned in `./Dockerfile`. There are examples for several tools with different installation methods.

## Inputs

For ArgoCD only `argocd_server` and `argocd_token` must be supplied, for other commands all other inputs are required.

#### `command`

The command to execute.

#### `gcp_credentials`

The GCP credentials to use for authentication.

#### `project`

The GCP project in which the GKE cluster runs.

#### `zone`

The GCP zone of the project.

#### `cluster`

The name of the GKE cluster.

#### `namespace`

The namespace in the GKE cluster.

#### `argocd_token`

The token for ArgoCD authentication.

#### `argocd_server`

The address of the ArgoCD server.


## Example Usage


```yaml
- uses: ZeitOnline/gh-action-gke-deployer@v0
  with:
    gcp_credentials: ${{ secret.GCP_CREDENTIALS }}
    project: 'my-awesome-gcp-project'
    zone: 'europe-west3-a'
    cluster: 'staging'
    namespace: 'my-namespace'
- run: kubectl get deployments
```

or

```yaml
- uses: ZeitOnline/gh-action-gke-deployer@v0
  - with:
    argocd_token: ${{ secret.ARGOCD_TOKEN }}
    argocd_server: 'https://argocd.mycompany.tld'
- run: argocd sync
```
