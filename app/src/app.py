import os
import traceback

from flask import Flask, escape, jsonify, request
from flask_expects_json import expects_json

from date_helper import DateHelper
from dynamodb_storage import DynamoDbStorage
from exceptions import UserAlreadyExistsException, UserNotFoundException
from user import User

app = Flask(__name__)

RV_ECS_APP_DYNDB_TABLE = os.getenv('RV_ECS_APP_DYNDB_TABLE', "revolut_interview")
RV_ECS_APP_FORCE_LOCAL_MODE = os.getenv('RV_ECS_APP_FORCE_LOCAL_MODE', str(app.debug)) == "True"

persistence = DynamoDbStorage(RV_ECS_APP_DYNDB_TABLE, RV_ECS_APP_FORCE_LOCAL_MODE)

@app.route("/", methods=["GET"])
def root():
    return "revolut-interview: Adrian Nieto <adrian.nieper@gmail.com>"

@app.route("/health", methods=["GET"])
def health():
    persistence_is_healthy = persistence.is_healthy()
    response = jsonify(web="OK", persistence="OK" if persistence_is_healthy else "KO")
    response.status_code = 200 if persistence_is_healthy else 503
    return response

@app.route("/hello/<name>", methods=["GET"])
def hello_get(name):
    if not User.is_valid_name(name):
        app.logger.warn("Invalid user %s syntax", name)
        response = jsonify(error="Invalid name")
        response.status_code = 400
        return response

    try:
        app.logger.info("Retrieving data for user %s", name)
        user = persistence.get_user(name)
        days_to_birthday = DateHelper.days_until_next_occurence_of(user.birth_date)

        if days_to_birthday > 0:  # days_to_birthday is always >=0
            response = jsonify(
                message=f"Hello, {escape(name)}, your birthday is in {days_to_birthday} day(s)!")
        else:
            response = jsonify(
                message=f"Hello, {escape(name)}, Happy birthday!")

        response.status_code = 200
        return response

    except UserNotFoundException:
        app.logger.warn("User %s not found", name)
        response = jsonify(error="User not found")
        response.status_code = 404
        return response
    except Exception:
        print(traceback.format_exc())
        response = jsonify(error="Internal server error")
        response.status_code = 500
        return response


put_hello_json_schema = {
  "type": "object",
  "properties": {
    "dateOfBirth": { "type": "string" }
  },
  "required": ["dateOfBirth"]
}

@app.route("/hello/<name>", methods=["PUT"])
@expects_json(put_hello_json_schema)
def hello_put(name):
    if not User.is_valid_name(name):
        app.logger.warn("Invalid user %s syntax", name)
        response = jsonify(error="Invalid name")
        response.status_code = 400
        return response

    data = request.get_json(silent=True)

    if data is None:
        app.logger.warn("Invalid JSON payload recived")
        response = jsonify(error="Invalid JSON")
        response.status_code = 400
        return response


    birth_date = data.get("dateOfBirth", None)

    if name is None or birth_date is None:
        app.logger.warn("Invalid JSON payload recived")
        response.status_code = 400
        return response

    try:
        app.logger.info("Trying to add new user %s with birth date %s", name, birth_date)
        persistence.put_user(name, birth_date)
        app.logger.info("User %s added", name)
        return "", 200

    except UserAlreadyExistsException:
        app.logger.warn("User %s already exists", name)
        response = jsonify(error="User already exists")
        response.status_code = 409
        return response
    except Exception:
        print(traceback.format_exc())
        response = jsonify(error="Internal server error")
        response.status_code = 500
        return response

if __name__ == '__main__':
    app.run()
