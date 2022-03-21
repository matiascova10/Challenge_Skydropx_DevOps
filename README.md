# Challenge Skydropx

_Este proyecto se centra en la creacion de un cluster de Kubernetes en AWS (EKS) con nodos en una VPC con diferentes rangos de red y Availability Zones, a su vez cada nodo
corre uno o mas pods con un servicio de Nginx que muestra la IP interna. El servicio es balanceado con ELB (Elastic Load Balancer) y posee un scaling group en los nodos como
tambien en los pods utilizando HPA. El deploy de los pods es realizado a traves de CI/CD con GithubActions_

### Pre-requisitos 📋

_-Cuenta en AWS_
  
    El proyecto corre en la region us-east-1 (N.Virginia)
  
_-Tener instalado AWS CLI_

_-Tener instalado Kubectl_

_-Tener instalado Terraform_

_-Tener instalado Github CLI_

## Comenzando 🚀

_Es necesario realizar las siguientes acciones_

   _-hacer Fork del proyecto_
   
   _-Ir a :gear: **Settings** -> **Secrets** -> **Actions** y agregar las siguientes variables de entorno_
   
    
      AWS_ACCESS_KEY_ID 
      AWS_SECRET_ACCESS_KEY
    
    
   _ejecutando **cat ~/.aws/credentials** va a poder observar la informacion en su consola_
   
### Instalación 🔧

_Inicializar terraform en el directorio /k8-aws-tf/_

```
terraform init
```

_Revisar plan de implementacion_

```
terraform plan
```

_Se crearan 25 recursos_

```
Plan: 25 to add, 0 to change, 0 to destroy.
```

_Aplicar los cambios_

```
terraform apply
o
terraform apply --auto-approve
```

_Aplicar los cambios puede llegar a tomar alrededor de 15 min :timer_clock:_

```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.
```

_Actualizar nuestro archivo de kubeconfig_

```
aws eks --region us-east-1 update-kubeconfig --name KuberCluster
```

_Nos movemos a la carpeta raiz y ejecutamos_

```
gh workflow run
```

_Seleccionamos el workflow Build (kubectl.yml)_

![select_workflow](https://user-images.githubusercontent.com/99150735/159172649-f243a059-c2fd-494e-a654-58d1692bd00e.png)

_Luego revisamos la lista de ejecuciones_

```
gh run list --workflow=kubectl.yml
```

_Deberiamos ver el proceso de ejecucion y finalizacion luego de unos 30 sec_

![pending](https://user-images.githubusercontent.com/99150735/159172736-f229bbd8-a69c-4112-9506-41d2ce88580e.png)
![done](https://user-images.githubusercontent.com/99150735/159172739-d1b167cd-f2f9-4575-aac6-b6623adbc36d.png)


## Ejecutando las pruebas ⚙️

_Revisar el estado de nuestro cluster_

```
aws eks --region us-east-1 describe-cluster --name KuberCluster --query cluster.status

"ACTIVE"
```

_Revisar nuestros servicios activos_

```
kubectl get svc

NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
kubernetes                   ClusterIP      172.20.0.1       <none>                                                                    443/TCP        28m
nginx-service-loadbalancer   LoadBalancer   172.20.147.238   ac7e7c41871fa419480350d7fe5ce0df-2061708622.us-east-1.elb.amazonaws.com   80:30078/TCP   7m50s       
```

_Revisar nodos y pods_

```
kubectl get nodes -o wide

NAME                         STATUS   ROLES    AGE   VERSION               INTERNAL-IP   EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                CONTAINER-RUNTIME
ip-10-0-0-138.ec2.internal   Ready    <none>   23m   v1.21.5-eks-9017834   10.0.0.138    <none>        Amazon Linux 2   5.4.181-99.354.amzn2.x86_64   docker://20.10.7
ip-10-0-0-168.ec2.internal   Ready    <none>   23m   v1.21.5-eks-9017834   10.0.0.168    <none>        Amazon Linux 2   5.4.181-99.354.amzn2.x86_64   docker://20.10.7
ip-10-0-0-217.ec2.internal   Ready    <none>   23m   v1.21.5-eks-9017834   10.0.0.217    <none>        Amazon Linux 2   5.4.181-99.354.amzn2.x86_64   docker://20.10.7
ip-10-0-0-223.ec2.internal   Ready    <none>   23m   v1.21.5-eks-9017834   10.0.0.223    <none>        Amazon Linux 2   5.4.181-99.354.amzn2.x86_64   docker://20.10.7

kubectl get pods -o wide 

NAME                                READY   STATUS    RESTARTS   AGE     IP           NODE                         NOMINATED NODE   READINESS GATES
nginx-deployment-5c6874647d-wlcdw   1/1     Running   0          9m19s   10.0.0.146   ip-10-0-0-138.ec2.internal   <none>           <none>
nginx-deployment-5c6874647d-zznmw   1/1     Running   0          9m19s   10.0.0.245   ip-10-0-0-223.ec2.internal   <none>           <none>

```

_Revisamos el AutoScaling de los pods_

```
kubectl get hpa -o wide

NAME   REFERENCE                     TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
hpa    Deployment/nginx-deployment   0%/41%    2         6         2          10m

```

_Ingresar a la EXTERNAL-IP de nuestro LoadBalancer_

http://<your_external_LoadBalancer_ip>

o

curl <your_external_LoadBalancer_ip> | grep "Server address:"

_y visualizar el servicio funcionando_

![output_curl](https://user-images.githubusercontent.com/99150735/159173195-c2157c41-5977-450e-ac61-1ed1b2fce1a6.png)
![web_test](https://user-images.githubusercontent.com/99150735/159173225-639ffd6c-7c99-4ff9-8703-e4c5796c6b6b.png)


_Probar AutoScaling con https://loadium.io/_ -> Http Test

_Completar el Test con los valores default y agregar la URL en el **HTTP Target**_

_Esperar a que comience el test_

![Loadtest](https://user-images.githubusercontent.com/99150735/159173837-bf7ea830-f9cd-4843-8cfa-330e92d984b4.png)

_Desde la consola podremos empezar a revisar el incremento_

![HPA test](https://user-images.githubusercontent.com/99150735/159174208-8814abe7-38b1-4329-bf2f-5a6ba8eba77d.png)

_Luego se podra visualizar como los pods se eliminan y vuelven a quedar dos replicas_

![HPA normal](https://user-images.githubusercontent.com/99150735/159174267-ac53bb32-6793-4a53-b8d0-b96095882b46.png)


## Destruir infraestructura :zap:

_No olvidar de destruir la infraestructura ya que hay servicios que no son gratis y generan gastos_

```
kubectl delete -f hpa.yml
kubectl delete -f deployment_ngnix.yml
kubectl delete -f lb.yml

terraform destroy --auto-approve
```
