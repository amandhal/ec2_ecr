### Create an SSH key pair
```ssh-keygen -t rsa```

Press enter thrice after running this command


### Clone this Repo to deploy the required infrastructure using Terraform
```git clone https://github.com/amandhal/ec2_ecr.git```


### Change your current directory to ec2_ecr
```cd ec2_ecr```


### Deploy the required Infrastructure
```terraform init```

```terraform apply --auto-approve```


### Login to EC2 instance
```ssh -i ~/.ssh/id_rsa ec2-user@<public_ip>```

Replace public_ip with the actual public_ip of deployed EC2 instance
