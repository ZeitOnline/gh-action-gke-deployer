FROM google/cloud-sdk:slim

ENV KUBECTL_VERSION 1.18.18
ENV KUSTOMIZE_VERSION 4.1.3
ENV JSONNET_VERSION 0.17.0
ENV JSONNET_BUNDLER_VERSION 0.4.0
ENV KUBECFG_VERSION 0.20.0
ENV PLUTO_VERSION 4.2.0
ENV LINKERD_VERSION 2.11.1
ENV JQ_VERSION 1.6
ENV ARGO_CLI_VERSION 2.1.7

RUN curl -L https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -o /usr/bin/jq \
  && chmod +x /usr/bin/jq

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl \
  && chmod +x /usr/bin/kubectl

ADD https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz /tmp/kustomize.tar.gz
RUN tar -C /tmp -xzf /tmp/kustomize.tar.gz \
  && mv /tmp/kustomize /usr/bin \
  && rm -f /tmp/kustomize*

RUN mkdir jsonnetdownload && cd jsonnetdownload && curl -fSL -o jsonnet.tar.gz https://github.com/google/jsonnet/releases/download/v${JSONNET_VERSION}/jsonnet-bin-v${JSONNET_VERSION}-linux.tar.gz && \
    tar xzf jsonnet.tar.gz && \
    mv jsonnet /usr/bin && \
    mv jsonnetfmt /usr/bin && \
    cd .. && \
    rm -rf jsonnetdownload

ADD https://github.com/FairwindsOps/pluto/releases/download/v${PLUTO_VERSION}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz /tmp/pluto.tar.gz
RUN tar -C /tmp -xzf /tmp/pluto.tar.gz \
  && mv /tmp/pluto /usr/bin \
  && rm -f /tmp/pluto*

RUN curl -L https://github.com/bitnami/kubecfg/releases/download/v${KUBECFG_VERSION}/kubecfg-linux-amd64 -o /usr/bin/kubecfg \
  && chmod +x /usr/bin/kubecfg

RUN curl -L https://github.com/linkerd/linkerd2/releases/download/stable-${LINKERD_VERSION}/linkerd2-cli-stable-${LINKERD_VERSION}-linux-amd64 -o /usr/bin/linkerd \
  && chmod +x /usr/bin/linkerd

RUN curl -fSL -o "/usr/bin/jb" "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${JSONNET_BUNDLER_VERSION}/jb-linux-amd64" && chmod a+x "/usr/bin/jb"

RUN curl -sSL -o /usr/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGO_CLI_VERSION}/argocd-linux-amd64 \
  && chmod +x /usr/bin/argocd

RUN mv /usr/bin/kubectl /usr/bin/kubectl.original
COPY ./gcloud-auth-wrapper.sh /usr/bin/kubectl

RUN mv /usr/bin/kubecfg /usr/bin/kubecfg.original
COPY ./gcloud-auth-wrapper.sh /usr/bin/kubecfg

RUN mv /usr/bin/gcloud /usr/bin/gcloud.original
COPY ./gcloud-auth-wrapper.sh /usr/bin/gcloud

RUN mv /usr/bin/gsutil /usr/bin/gsutil.original
COPY ./gcloud-auth-wrapper.sh /usr/bin/gsutil

RUN mv /usr/bin/linkerd /usr/bin/linkerd.original
COPY ./gcloud-auth-wrapper.sh /usr/bin/linkerd

RUN mv /usr/bin/argocd /usr/bin/argocd.original
COPY ./gcloud-auth-wrapper.sh /usr/bin/argocd