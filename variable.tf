variable "project_name" {
  type        = string
  description = "This is a bucket name"

  # validate variable 
  # validation {
  #   condition = contains(["nf-1", "nf-2"], var.project_name)
  #   error_message = "Value not allow."
  # }
}
