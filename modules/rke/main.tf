data "rke_node_parameter" "nodes" {
  #count   = "${length(var.addresses)}"
  address           = "${var.addresses[count.index]}"
  node_name         = "${var.node_names[count.index]}"
  hostname_override = "${var.node_names[count.index]}"
  user              = "core"
  role              = ["controlplane", "worker", "etcd"]
  ssh_key           = "${var.ssh_key}"
}

resource rke_cluster "cluster" {
  ignore_docker_version = true
  nodes_conf            = ["${data.rke_node_parameter.nodes.*.json}"]

  ingress = {
    provider = "none"
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
---

EOL

  addons_include = [
    "https://raw.githubusercontent.com/digitalocean/digitalocean-cloud-controller-manager/master/releases/v0.1.7.yml",
  ]
}
