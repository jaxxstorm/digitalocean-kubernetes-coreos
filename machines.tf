module "k8s" {
  count               = 1
  source              = "modules/droplet"
  digitalocean_domain = "${var.digital_ocean_domain}"
  digitalocean_keys   = "${digitalocean_ssh_key.personal.id}"
  name                = "k8s"
}

/*
resource "digitalocean_loadbalancer" "public" {
  name   = "rancher"
  region = "sfo2"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "tcp"

    target_port     = 80
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "tcp"

    target_port     = 443
    target_protocol = "tcp"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = ["${module.rancher-server.ids}"]
}

resource "digitalocean_record" "public" {
  domain = "${var.digital_ocean_domain}"
  type   = "A"
  name   = "rancher"
  value  = "${digitalocean_loadbalancer.public.ip}"
  ttl    = 60
}
*/

module "rancher" {
  source               = "modules/rke"
  ssh_key              = "${file("~/.ssh/id_rsa_personal")}"
  addresses            = ["${module.k8s.addresses}"]
  node_names           = ["${module.k8s.names}"]
  kube_config_path     = "/tmp/rancher.yaml"
  digital_ocean_token  = "${var.digital_ocean_token}"
  digital_ocean_domain = "${var.digital_ocean_domain}"
}
