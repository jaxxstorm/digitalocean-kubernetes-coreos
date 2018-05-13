#cloud-config
hostname: "${fqdn}"
fqdn: "${fqdn}"

runcmd:
  - mkdir -p /opt/{bin,cni}/bin
  - curl -L "https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz" | tar -C /opt/cni/bin -xz
  - cd /opt/bin
  - curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/{kubeadm,kubelet,kubectl}
  - chmod +x {kubeadm,kubelet,kubectl}
  - curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.2/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
  - mkdir -p /etc/systemd/system/kubelet.service.d
  - curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.2/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  - systemctl enable kubelet && systemctl start kubelet
