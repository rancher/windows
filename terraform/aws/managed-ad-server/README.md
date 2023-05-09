# AWS Managed Active Directory Server


## Usage
Use of this terraform requires the proper AWS permissions for creating and managing Directory Services.

[Set your variables](#variables-files).

[Configure the AWS provider with your credentials](#configuring-the-aws-provider-to-consume-your-aws-credentials-file)

Run `terraform init`. 

Run `terraform apply`. 

When complete, run `terraform destroy` to destroy all terraform-managed resources.

### Variables Files
Copy `default.auto.tfvars.example` to `default.auto.tfvars` and set your configuration there.

Example:
```
#### Variable definitions
owner                   = "rosskirkpatrick" # owner tag value for AWS to avoid cleanup by cloud custodian
aws_credentials_file    = "/Users/ross/.aws/credentials" # full path to your local AWS credentials file
aws_region              = "us-east-1" # pick your preferred aws region
```

### Configuring the AWS provider to consume your AWS credentials file

Preferred method is to configure the `shared_credentials_file` variable in the `default.auto.tfvars` file with the full path of the AWS credentials file. 

Alternate method:

**Linux/macOS**

`terraform apply -var=shared_credentials_file=$HOME/.aws/credentials"`

**Windows**

`terraform apply -var "shared_credentials_file=[\"%USERPROFILE%\\.aws\\credentials"]"`


### How to authenticate with the AWS terraform provider
https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file

> You can use an AWS credentials or configuration file to specify your credentials. The default location is $HOME/.aws/credentials on Linux and macOS, or "%USERPROFILE%\.aws\credentials" on Windows. 


Example: Creating a linux/macOS AWS credentials file with profile name `default`

```shell
mkdir -p $HOME/.aws/credentials
cat << EOF > $HOME/.aws/credentials
[default]
aws_access_key_id=XXXX
aws_secret_access_key=YYYYY
EOF
```


Example: Creating a Windows AWS credentials file with profile name `default`

```powershell
powershell
New-Item -Type Directory -Path "%USERPROFILE%\\.aws" -Force

$CrendentialString = @" 
[default]
aws_access_key_id=XXXX
aws_secret_access_key=YYYYY
"@

New-Item -ItemType File -Path "%USERPROFILE%\\.aws\\credentials" -Value $CredentialString
```



Useful Content:

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/directory_service_directory

https://registry.terraform.io/providers/hashicorp/ad/latest/docs

https://docs.aws.amazon.com/directoryservice/latest/admin-guide/ms_ad_key_concepts_gmsa.html