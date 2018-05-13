resource "digitalocean_domain" "default" {
  name       = "${var.digital_ocean_domain}"
  ip_address = "127.0.0.1"
}

resource "digitalocean_record" "mail" {
  name     = "@"
  domain   = "${digitalocean_domain.default.name}"
  type     = "MX"
  value    = "alt1.aspmx.l.google.com."
  priority = 5
}

resource "digitalocean_record" "mail-2" {
  name     = "@"
  domain   = "${digitalocean_domain.default.name}"
  type     = "MX"
  value    = "alt2.aspmx.l.google.com."
  priority = 5
}

resource "digitalocean_record" "mail-3" {
  name     = "@"
  domain   = "${digitalocean_domain.default.name}"
  type     = "MX"
  value    = "aspmx2.googlemail.com."
  priority = 10
}

resource "digitalocean_record" "mail-4" {
  name     = "@"
  domain   = "${digitalocean_domain.default.name}"
  type     = "MX"
  value    = "aspmx3.googlemail.com."
  priority = 10
}

resource "digitalocean_record" "mail-5" {
  name     = "@"
  domain   = "${digitalocean_domain.default.name}"
  type     = "MX"
  value    = "aspmx.l.google.com."
  priority = 1
}
