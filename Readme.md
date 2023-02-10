# revolut-interview

#### Tradeoffs
I tried to make a "real app" but given the constrains of the time there are certain things are not being done on purpose:
- Deeper and more tests
- Authentication (we could add a layer on top with Cognito or similar for fast auth, but internaly would stil remain unauth without code changes)
- Fancy CICD tools like Sonarqube are not added, as they dont have free-tier for non-open source apps
- Swagger
- HTTPS
- No ARM support, which would be nice to save costs



## Architecture

I chose EKS instead of ECS because even if ECS would be simpler and faster to implement I think it's not where market is pushing (k8s instead of propietary implementations), and also comes with a strong vendor locking.

Another alternative for an API would be to use AWS Lambda, but as we dont have any specs on the traffic pattern (critical for Lambda usage due costs) I wouldn't consider it neither, as first I assume the purpose of the test is to prove I can also code some nice Terraform and Lambda would make something like Api Gateway > Lambda > Dynamo.  



## Getting started

### Requeriments

- pyenv https://github.com/pyenv/pyenv

### EKS

#### Development
In order to run in development mode follow this steps:

```
cd ecs/app

pyenv install 3.9.2
pyenv virtualenv 3.9.16 revolut-interview-ecs-app 
pyenv activate revolut-interview-ecs-app 
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

#### Production


