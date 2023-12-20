# Quiter Template Project

Este proyecto se usa para desplegar la infraestructura de un proyecto de despliegue de Quiter.

Notas:
- Antes de implementar es necesario suscribir la cuenta para usar el ami de centos: ami-02358d9f5245918a3
- El proyecto usa el rol OrganizationAccountAccessRole como default para implementar quiter. Por el momento es necesario agregar la cuenta de devops sobre la que corre Gitlab como Trusted entity para implementar sobre las cuentas dentro de la organizacion de totalcloud
- Se debe agregar el nombre de la rama de produccion del cliente al only gitlab-ci


## Probar local:
terraform init -backend-config="key=env:/test/totaldeploy/quiter/cf-templates/test/terraform.tfstate"