data "aws_launch_template" "POC" {
  name = aws_launch_template.POC.name

  depends_on = [aws_launch_template.POC]
}

resource "aws_launch_template" "POC" {
  name          = "POC"
  #image_id = "ami-0c6f20e00e2f5869a"
  instance_type = var.instance_type["dev_env"]
  #default_version         =  1 
  update_default_version = true #Actualiza default_version a la última_versión en terraform apply 
  #user_data = filebase64("${path.module}/scripts/userdata.sh")
}

## Define ami queriar a lo macho :)

