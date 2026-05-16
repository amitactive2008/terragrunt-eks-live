# terragrunt-eks-live
```
Create EKS cluster with terragrunt. Ref module is in amitactive2008/terragrunt-eks-module
## Create S3 Bucket with versioning enabled. Now with terrform 1.11 no need of dynamodb table lock
```


## Create a IAM user with assume role of Admin.
```
- role terraform , permission Admin access
- Create policy name AllowTerraform with sts assume role policy 
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"sts:AssumeRole"
			],
			"Resource": "arn:aws:iam::088317451471:role/terraform"
		}
	]
}

- Create group devops with AllowTerraform policy , Add IAM user(Example : amit ) to devops Group
- Now any user with devops group would have terraform assume role access. Generate AWS cred for user=amit and use this in terragrunt cred for infra provision.
- Now configure cred on the system
[default]
aws_access_key_id = A********72
aws_secret_access_key = 2*********l
[amit]
aws_access_key_id = S*******W
aws_secret_access_key = 2*******A
```
- Replace your aws account id from 123456789 to your account id 

** INIT ** 
terragrunt init -upgrade

** PLAN , Apply and Destroy Command** 
```
terragrunt run --all plan
terragrunt run --all apply --non-interactive
terragrunt run --all destroy --non-interactive
```

** Once cluster created you can generate your kubeconfig **
```
aws eks update-kubeconfig --region <region-code> --name <cluster-name>
```
** To test Autoscaling you can deploy nginx deployment and watch nodes to be added. **
```
kubectl apply -f demo-deployment/deployment.yaml
kubectl get no -w
```