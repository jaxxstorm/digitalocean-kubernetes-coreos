output "addresses" {
  value = ["${digitalocean_droplet.droplet.*.ipv4_address}"]
}

output "ids" {
  value = ["${digitalocean_droplet.droplet.*.id}"]
}

output "names" {
  value = ["${digitalocean_droplet.droplet.*.name}"]
}
