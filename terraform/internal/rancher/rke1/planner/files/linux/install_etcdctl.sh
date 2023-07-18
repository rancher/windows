wget https://github.com/etcd-io/etcd/releases/download/${etcdctl_version}/etcd-${etcdctl_version}-linux-amd64.tar.gz
tar -xvzf etcd-${etcdctl_version}-linux-amd64.tar.gz etcd-${etcdctl_version}-linux-amd64/etcdctl 
mv etcd-${etcdctl_version}-linux-amd64/etcdctl /usr/local/bin/etcdctl

cat >> /etc/profile <<EOF
export ETCDCTL_ENDPOINTS='https://127.0.0.1:2379';
export ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt';
export ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt';
export ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key';
export ETCDCTL_API=3;
EOF