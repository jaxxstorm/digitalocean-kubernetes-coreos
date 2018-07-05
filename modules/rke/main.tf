data "rke_node_parameter" "nodes" {
  #count   = "${length(var.addresses)}"
  address = "${var.addresses[count.index]}"
  user    = "core"
  role    = ["controlplane", "worker", "etcd"]
  ssh_key = "${var.ssh_key}"
}

resource rke_cluster "cluster" {
  ignore_docker_version = true
  nodes_conf            = ["${data.rke_node_parameter.nodes.*.json}"]

  ingress = {
    provider = "nginx"
  }

  services_kubelet {
    extra_args = {
      cloud-provider = "external"
    }
  }

  authorization {
    mode = "rbac"
  }

  addons = <<EOL
---
apiVersion: v1
kind: Secret
metadata:
  name: digitalocean
  namespace: kube-system
stringData:
  # insert your DO access token here
  access-token: "${var.digital_ocean_token}"
EOL

  addons_include = [
    "https://raw.githubusercontent.com/digitalocean/digitalocean-cloud-controller-manager/master/releases/v0.1.6.yml",
    "https://raw.githubusercontent.com/jetstack/cert-manager/master/contrib/manifests/cert-manager/with-rbac.yaml",
  ]
}
