resource "aws_key_pair" "project" {
  key_name   = "observability-project-key"
  public_key = file(pathexpand("~/.ssh/observability-project.pub"))

  tags = {
    Name = "observability-project-key"
  }
}
