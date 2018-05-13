# Token

variable "name" {}

variable "digitalocean_keys" {}

variable "digitalocean_domain" {}

variable "digitalocean_region" {
  default = "sfo2"
}

variable "digitalocean_droplet_size" {
  default = "2gb"
}

variable "count" {
  default = 1
}
