# ECR Repo Names
variable "ecr_repo_names" {
  default = ["my_db", "my_app"]
  type    = list(string)
}
