cat >> /etc/profile <<EOF
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
alias k=kubectl
EOF