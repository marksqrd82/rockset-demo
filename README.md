# Summary

I performed no manual steps and automated from the start to avoid duplicate work.

I decided to provision resources using Terraform.  I used the following standard and well known modules for both EKS and VPC/network resources.

- EKS: terraform-aws-modules/vpc/aws
- AWS: terraform-aws-modules/eks/aws

I tweaked the module arguments to create the cluster of the desired size using the **t3.small** instance type.

I setup a load balancer controller using helm charts: "aws-load-balancer-controller"

I configured CIDR, region, namespace, etc in one file: **main.tf**

# Steps I performed locally

Once the code was written, I only needed to perform the following to provision all resources with Terraform:

```
terraform init
terraform plan # check changes
terraform apply -auto-approve
```

To setup kubectl locally I ran:

```
aws eks update-kubeconfig --name rockset-demo --region us-west-2
```

# Application

For the application - I decided to run nginx and create a script that runs after the pod is started.  This script sets up the site dynamically on each pod by writing the relative environment variables to the nginx public html directory.  I pass this script by creating a config map and mounting it to the deployment.  I then run the script as a post-start command.

```
#!/bin/bash

cat > /usr/share/nginx/html/index.html <<EOF
Pod: $K8_POD_NAME
Node: $K8_NODE_NAME
Namespace: $K8_POD_NAMESPACE
IP: $K8_POD_IP
EOF
```

# Difficulties

Getting everything working was pretty simple with my implementation.  The difficulties were avoiding temptations to over-complicate and extending over 2 hours.

Just using the base image with a post-init script was a simple enough solution to complete in the time alloted. 

# Improvements

If I had more time - I would have included https/443 and setup a valid cert and redirect traffic from non-ssl port 80 to ssl port 443.  I would have implemented a more proper service, such as setting up an internal ECS repo and building an actual image.  This still requires invoking via CLI - in actual practice I would set this up in the companies CI/CD pipeline of choice.

# Validation

I created a CNAME from a domain I own to the LoadBalancer for easy access. (also done in Terraform - see [route53.tf](https://github.com/marksqrd82/rockset-demo/blob/main/route53.tf))

The Loadbalancer can be reached at: [rockset.cryptic.net](http://rockset.cryptic.net)

```
curl http://rockset.cryptic.net
```
# Test

I tested by making 100 requests to the LB endpoint.  I validated by observing a fairly even distribution of pod names.

Here are my results:

```
$ declare -i cnt=100 ; while (( --cnt )); do curl -s rockset.cryptic.net; done | sort | uniq -cd
     31 IP: 10.0.14.223
     33 IP: 10.0.18.106
     35 IP: 10.0.35.25
     99 Namespace: rockset-demo
     31 Node: ip-10-0-13-114.us-west-2.compute.internal
     33 Node: ip-10-0-22-80.us-west-2.compute.internal
     35 Node: ip-10-0-38-4.us-west-2.compute.internal
     33 Pod: deployment-demo-556df59955-pqxwv
     35 Pod: deployment-demo-556df59955-srrff
     31 Pod: deployment-demo-556df59955-vp4ql
```
