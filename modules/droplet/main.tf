data "template_file" "droplet_user_data" {
  template = "${file("${path.module}/templates/droplet.tpl")}"
  count    = "${var.count}"

  vars {
    hostname = "${var.name}-${count.index}"
    domain   = "${var.digitalocean_domain}"
    fqdn     = "${var.name}-${count.index}.${var.digitalocean_domain}"
  }
}

resource "digitalocean_droplet" "droplet" {
  count              = "${var.count}"
  image              = "coreos-beta"
  name               = "${var.name}-${count.index}"
  region             = "${var.digitalocean_region}"
  size               = "${var.digitalocean_droplet_size}"
  private_networking = true
  ssh_keys           = ["${var.digitalocean_keys}"]
  user_data          = "${element(data.template_file.droplet_user_data.*.rendered,count.index)}"
}

resource "digitalocean_record" "droplet" {
  count  = "${var.count}"
  domain = "${var.digitalocean_domain}"
  type   = "A"
  name   = "${var.name}-${count.index}"
  value  = "${element(digitalocean_droplet.droplet.*.ipv4_address_private, count.index)}"
}
