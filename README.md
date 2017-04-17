<pre>
$ git clone https://github.com/vandocouto/terraform-aws-vpc.git
</pre>

<pre>
$ cd terraform-aws-vpc/
</pre>

### Create script deploy.sh

<pre>
$ vim deploy.sh
</pre>

<pre>
#!/usr/bin/env bash
if [ -z "$1" ]
then
  echo "Usage: must pass the terraform directory"
  exit 1
fi

# Access Key and Secret Key Report
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION="us-west-1"

cd $1
terraform $2
</pre>

###### Set permission

<pre>
$ chmod +x deploy.sh
</pre>

### Configure the variable file

###### Adjust the variable file
<pre>
$ vim terraform/default/variables.tf
</pre>

### Deploy

Step 1 - After tuning, run the command below
<pre>
 ./deploy.sh default plan
 </pre>
 
Step 2 - Building the Infrastructure
<pre>
 ./deploy.sh default apply
 </pre>
 
### Destroy project

<pre>
 ./deploy.sh default destroy
 </pre>