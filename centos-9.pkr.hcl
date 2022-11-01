variable "iso_url" {
  type    = string
  // This can be a local file or URL
  default = "http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"
}

variable "iso_checksum" {
  type    = string
  // This can be a local file, URL or a specific checksum
  default = "file:http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso.SHA256SUM"
}

source "qemu" "centos9" {
  iso_url           = "${var.iso_url}"
  iso_checksum      = "${var.iso_checksum}"
  output_directory  = "images"
  shutdown_command  = "echo 'packer' | sudo -S /sbin/halt -h -p"
  disk_size         = "8192M"
  memory            = "2048"
  cpus              = "2"
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "httpdir"
  headless          = "true"
  communicator      = "none"
  shutdown_timeout  = "30m"
  vm_name           = "centos-9-latest-ext4"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  skip_compaction   = "false"
  disk_compression  = "true"
  boot_wait         = "10s"
  boot_command      = ["<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos9-ext4.ks<enter><wait>"]
  qemuargs          = [
    [ "-m", "2048" ],
    [ "--cpu", "kvm64" ]
  ]
}

build {
  sources = ["source.qemu.centos9"]
}
