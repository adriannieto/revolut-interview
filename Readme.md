# revolut-interview

## Architecture

### ECS

#### Tradeoffs
- Application is meant to be simple, even if unit test are added we are not adding type checks and other stuff that could 
- Selfsigned certificates, in production we would require to a valid CA via cert-manager or whatever in each container

### Lambda


## Getting started

### Requeriments

- pyenv https://github.com/pyenv/pyenv

### ECS

#### Development
In order to run in development mode follow this steps:

```
cd ecs/app

pyenv install 3.9.2
pyenv virtualenv 3.9.16 revolut-interview-ecs-app 
pyenv activate revolut-interview-ecs-app 
pip install -r requirements.txt
pip install -r requeriments_test.txt

# Run unit tests
pytest

# Run type checks
mypy .

# Run pylint
pylint *.py **/*.py

# Start local dynamodb
docker run --name dynamodb -it -p 8000:8000 amazon/dynamodb-local

# Run app in dev mode
flask --app src/app.py --debug run
```

#### Production


