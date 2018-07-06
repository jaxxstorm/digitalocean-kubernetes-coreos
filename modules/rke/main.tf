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
apiVersion: v1
kind: Namespace
metadata:
  name: external-dns
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  namespace: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions"]
  resources: ["ingresses"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: external-dns
---
apiVersion: v1
kind: Secret
metadata:
  name: external-dns-do-secret
  namespace: external-dns
data:
  token: "${base64encode(var.digital_ocean_token)}"
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: external-dns
  namespace: external-dns
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: registry.opensource.zalan.do/teapot/external-dns:latest
        args:
        - --source=ingress
        - --domain-filter=${var.digital_ocean_domain}
        - --provider=digitalocean
        env:
        - name: DO_TOKEN
          valueFrom:
            secretKeyRef:
              name: external-dns-do-secret
              key: token
EOL

  addons_include = [
    "https://raw.githubusercontent.com/digitalocean/digitalocean-cloud-controller-manager/master/releases/v0.1.6.yml",
    "https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml",
    "${path.module}/manifests/nginx-service.yaml",
  ]
}
