# revolut-interview

#### Tradeoffs

I tried to make a "real app" but given the constrains of the time there are certain things are not being done on purpose:

Python app:
- Deeper and more tests
- Authentication (we could add a layer on top with Cognito or similar for fast auth, but internaly would stil remain unauth without code changes)
- Fancy CICD tools like Sonarqube are not added, as they dont have free-tier for non-open source apps
- Swagger
- HTTPS
- No load test/smoke after deployment

Infrastructure:
- ECS in favor of EKS
- ECS autoscaling disabled
- In general only cloudwatch available logging/monitoring is there, no application level monitoring neither, only containers and infra
- No ARM support, which would be nice to save costs
- No terraform modules, infrastructure code is small enough as it is
- In-line security groups rules
- Single terraform state stored in S3, for multiple environments we need to configure multiple states

Misc:
- No github actions for pre commit validations 
- Improve github ci pipeline to be more reusable and clear to read, i'm not very used to github (i use gitlab) and it seems the way actions work are quite different in terms of orchestration



## Architecture

I chose ECS instead of EKS because complexity and free tier existence for this example. However with a little bit of more time and a demo account provided I would have chosen EKS as it reduces vendor locking and provides more flexbility for future developments in cross cloud environments.

Another alternative for an API would be to use AWS Lambda, but as we dont have any specs on the traffic pattern (critical for Lambda usage due costs) I wouldn't consider it neither, as first I assume the purpose of the test is to prove I can also code some nice Terraform and Lambda would make something like Api Gateway > Lambda > Dynamo.  


## Getting started

### Requeriments

- pyenv https://github.com/pyenv/pyenv 
- terraform
- s3 bucket created in aws to store terraform state

### Development
In order to run in development mode follow this steps:

```
cd app

pyenv install 3.9.2
pyenv virtualenv 3.9.16 revolut-interview-eks-app 
pyenv activate revolut-interview-eks-app 
pip install -r requirements.txt
pip install -r requirements_test.txt

# Run unit tests
pytest --junitxml=junit/test-results.xml .

# Run type checks
mypy .

# Run pylint
pylint **/*.py --fail-under=8  

# Start local dynamodb
docker run --name dynamodb -it -p 8000:8000 amazon/dynamodb-local

# Run app in dev mode
flask --app src/app.py --debug run
```

### Deployment
Deployment of all infrastructure is done by gitlab actions, however if we want to plan locally you will need to setup credentials for this

```
cd ecs

# Validate current code
terraform init 
terraform validate -var-file=prod.tfvars


# Run linter
tflint

# Run security scan
tfsec

# Format code
tf fmt

# Review costs for the current plan
infracost breakdown --path .  --terraform-var-file prod.tfvars


```


