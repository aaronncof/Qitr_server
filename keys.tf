/**
* Creamos la llave principal
*
* Nota: Esta llave es la con la que arrancan las instancias
* es esta la resguarda Totalcloud para uso en caso de soporte 
**/
resource "tls_private_key" "primary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/**
* Creamos la llave que usara quiter para acceder al bastion e instalar Quiter
**/
resource "tls_private_key" "quiter" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/**
* Creamos la llave que se le compartira al cliente para acceder a los servidores
* Esta llave se adjunta al servidor bastion para que quiter tambien pueda acceder a los servidores DMS y QAE
**/
resource "tls_private_key" "cliente" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/**
* Agregamos la llave principal a la consola de AWS
**/
resource "aws_key_pair" "aws-primary-key" {
  provider = aws.client
  depends_on = [tls_private_key.primary]
  key_name   = var.client
  public_key = tls_private_key.primary.public_key_openssh
  tags = { project = "quiter" }
}

/**
* Bajamos las llaves al disco para eviarlas a S3
**/
resource "local_file" "primary-key-pem" {
    content  = tls_private_key.primary.private_key_pem
    depends_on = [tls_private_key.primary]
    filename = "primary"
}
resource "local_file" "quiter-key-pem" {
    content  = tls_private_key.quiter.private_key_pem
    depends_on = [tls_private_key.quiter]
    filename = "quiter"
}
resource "local_file" "client-key-pem" {
    content  = tls_private_key.cliente.private_key_pem
    depends_on = [tls_private_key.cliente]
    filename = "client"
}

/**
* Subimos las llaves a S3
**/
resource "aws_s3_bucket_object" "primary-key" {
  depends_on = [local_file.primary-key-pem]
  provider = aws.dev-ops
  bucket = "custumer-keys"
  key    = "${var.client}/primary-key.pem"
  source = "./primary"
}
resource "aws_s3_bucket_object" "quiter-key" {
  depends_on = [local_file.quiter-key-pem]
  provider = aws.dev-ops
  bucket = "custumer-keys"
  key    = "${var.client}/quiter-key.pem"
  source = "./quiter"
}
resource "aws_s3_bucket_object" "client-key" {
  depends_on = [local_file.client-key-pem]
  provider = aws.dev-ops
  bucket = "custumer-keys"
  key    = "${var.client}/client-key.pem"
  source = "./client"
}
