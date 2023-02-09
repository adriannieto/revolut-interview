# pylint: disable=missing-class-docstring 
# pylint: disable=missing-module-docstring 
# pylint: disable=missing-function-docstring
import unittest

import boto3
from moto import mock_dynamodb
from src.dynamodb_storage import DynamoDbStorage
from src.exceptions import UserAlreadyExistsException, UserNotFoundException


class DynamoDbStorageTestCases(unittest.TestCase):

    __TEST_DB_NAME = "test-db"

    def __create_test_db(self):
        self.__dynamodb =  boto3.resource('dynamodb')
        table = self.__dynamodb.create_table(
            TableName=self.__TEST_DB_NAME,
            KeySchema=[
                {
                    'AttributeName': 'name',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'name',
                    'AttributeType': 'S'
                }
            ],
            BillingMode='PAY_PER_REQUEST'
        )

        table.wait_until_exists()

    @mock_dynamodb
    def test_init_ok_if_db_in_prod_mode(self):
        # Init mocked db
        self.__create_test_db()
        DynamoDbStorage(table_name=self.__TEST_DB_NAME)

    @mock_dynamodb
    def test_init_fails_if_no_db_in_prod_mode(self):
        with self.assertRaises(ValueError):
            persistence = DynamoDbStorage(table_name=self.__TEST_DB_NAME)


    @mock_dynamodb
    def test_get_user_that_does_not_exist(self):

        # Init mocked db
        self.__create_test_db()

        persistence = DynamoDbStorage(table_name=self.__TEST_DB_NAME)
        
        with self.assertRaises(Exception):
            persistence.get_user("adrian")

    @mock_dynamodb
    def test_get_user_that_exist(self):

        # Init mocked db
        self.__create_test_db()

        persistence = DynamoDbStorage(table_name=self.__TEST_DB_NAME)
        
        persistence.put_user("adrian", "1989-03-07")
        user = persistence.get_user("adrian")
        assert(user.name == "adrian")
        assert(user.get_birth_date_str() == "1989-03-07")


    @mock_dynamodb
    def test_put_user_that_not_exists(self):

        # Init mocked db
        self.__create_test_db()

        persistence = DynamoDbStorage(table_name=self.__TEST_DB_NAME)
        persistence.put_user("adrian", "1989-03-07")
        persistence.put_user("juan", "1000-03-07")

        user = persistence.get_user("adrian")

        assert(user.name == "adrian")
        assert(user.get_birth_date_str() == "1989-03-07")

        user = persistence.get_user("juan")
        assert(user.name == "juan")
        assert(user.get_birth_date_str() == "1000-03-07")

    @mock_dynamodb
    def test_put_user_that_exists(self):

        # Init mocked db
        self.__create_test_db()

        persistence = DynamoDbStorage(table_name=self.__TEST_DB_NAME)
        persistence.put_user("adrian", "1989-03-07")
        
        with self.assertRaises(Exception):
            persistence.put_user("adrian", "1989-03-07")

        user = persistence.get_user("adrian")

        assert(user.name == "adrian")
        assert(user.get_birth_date_str() == "1989-03-07")

