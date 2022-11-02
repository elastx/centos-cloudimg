variable "iso_url" {
  type    = string
  // This can be a local file or URL
  default = "http://mirror.nsc.liu.se/CentOS/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso"
}

variable "iso_checksum" {
  type    = string
  // This can be a local file, URL or a specific checksum
  default = "file:http://mirror.nsc.liu.se/CentOS/8-stream/isos/x86_64/CHECKSUM"
}

variable "cpu_flag" {
  type    = string
  // List available host flags with: qemu-system-x86_64 -enable-kvm -cpu help
  default = "host"
}

source "qemu" "centos8" {
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
  shutdown_timeout  = "60m"
  vm_name           = "centos-8-latest-ext4"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  skip_compaction   = "false"
  disk_compression  = "true"
  boot_wait         = "10s"
  boot_command      = ["<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos8-ext4.ks<enter><wait>"]
  qemuargs          = [
    [ "-m", "2048" ],
    [ "--cpu", "${var.cpu_flag}" ]
  ]
}

build {
  sources = ["source.qemu.centos8"]
}
