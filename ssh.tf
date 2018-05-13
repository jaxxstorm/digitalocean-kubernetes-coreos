resource "digitalocean_ssh_key" "personal" {
  name       = "personal_key"
  public_key = "${var.ssh_public_key}"
}
