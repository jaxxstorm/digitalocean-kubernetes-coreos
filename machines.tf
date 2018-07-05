module "rancher-server" {
  count               = 3
  source              = "modules/droplet"
  digitalocean_domain = "${var.digital_ocean_domain}"
  digitalocean_keys   = "${digitalocean_ssh_key.personal.id}"
  name                = "rancher"
}

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

module "rancher" {
  source    = "modules/rancher"
  ssh_key   = "${file("~/.ssh/id_rsa_personal")}"
  addresses = ["${module.rancher-server.addresses}"]
}
