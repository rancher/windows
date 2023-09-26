#!/bin/bash
set -e

KUBERNETES_USER="${user}"

FQDN="https://${api_server_address}:6443"

curr_dir="$(pwd)"
temp_dir=$(mktemp -d)

trap 'cleanup' EXIT

cleanup() {
  [[ -f $temp_dir/$KUBERNETES_USER.kubeconfig ]] && cp $temp_dir/$KUBERNETES_USER.kubeconfig $curr_dir/$KUBERNETES_USER.kubeconfig
  [[ -n "$temp_dir" ]] && rm -rf $temp_dir
}

cd $temp_dir

cat <<EOF > $KUBERNETES_USER.key
${trim(private_key_pem, "\n")}
EOF

cat <<EOF > $KUBERNETES_USER.csr
${trim(cert_request_pem, "\n")}
EOF

cat <<EOF > $KUBERNETES_USER-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
    name: $KUBERNETES_USER
spec:
    groups:
    - system:masters
    request: $(cat $KUBERNETES_USER.csr | base64 | tr -d "\n")
    signerName: kubernetes.io/kube-apiserver-client
    expirationSeconds: 2592000
    usages:
    - client auth
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $KUBERNETES_USER-cluster-admin
subjects:
- kind: User
  name: $KUBERNETES_USER
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f $KUBERNETES_USER-csr.yaml

kubectl certificate approve $KUBERNETES_USER

certificate=$(kubectl get csr $KUBERNETES_USER -o jsonpath='{.status.certificate}')
while [[ -z "$certificate" ]]; do
  echo "Waiting for certificate to be signed by the apiserver..."
  sleep 1
  certificate=$(kubectl get csr $KUBERNETES_USER -o jsonpath='{.status.certificate}')
done

echo $certificate | base64 -d > $KUBERNETES_USER.crt

cat <<EOF > $KUBERNETES_USER.kubeconfig
apiVersion: v1
kind: Config
users:
- name: $KUBERNETES_USER
  user:
    client-certificate-data: $(cat $KUBERNETES_USER.crt | base64 | tr -d "\n")
    client-key-data: $(cat $KUBERNETES_USER.key | base64 | tr -d "\n")
clusters:
- cluster:
    server: "$FQDN"
    insecure-skip-tls-verify: true
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: "$KUBERNETES_USER"
  name: $KUBERNETES_USER-context@kubernetes
current-context: $KUBERNETES_USER-context@kubernetes
EOF
