# Variables for your database username and password
variable "DB_USERNAME" {
  type = string
}

variable "DB_PASSWORD" {
  type = string
}

# Variables for SSM
variable "TECHRONOMICON_ACCESS_KEY_ID" {
  type = string
}

variable "TECHRONOMICON_SECRET_ACCESS_KEY" {
  type = string
}

variable "TECHRONOMICON_STORAGE_BUCKET_NAME" {
  type = string
}

variable "DJANGO_SECRET_KEY" {
  type = string
}

variable "TECHRONOMICON_RDS_DB_NAME" {
  type = string
}
