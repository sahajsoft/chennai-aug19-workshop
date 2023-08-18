variable "userName" {
  type = string
}

variable "cpuArchitecture" {
  default = "amd64"
  // change to arm64 if using apple silicon
}