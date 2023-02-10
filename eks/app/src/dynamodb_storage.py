import boto3
from exceptions import UserAlreadyExistsException, UserNotFoundException, InvalidUsernameException
from user import User


class DynamoDbStorage:

    def __init__(self, table_name: str = "revolut_interview", local_mode: bool = False):
        if local_mode:
            self.__dynamodb_resource = boto3.resource(
                'dynamodb', aws_access_key_id="dummy", aws_secret_access_key="dummy", endpoint_url='http://localhost:8000')
            self.__dynamodb_client = boto3.client(
                'dynamodb', aws_access_key_id="dummy", aws_secret_access_key="dummy", endpoint_url='http://localhost:8000')                
            self.__create_local_mode_table(table_name)
        else:
            self.__dynamodb_resource = boto3.resource('dynamodb')
            self.__dynamodb_client = boto3.client('dynamodb')

        self.__table = self.__dynamodb_resource.Table(table_name)

        if not self.is_healthy():
            raise ValueError(f"Unable to find DynamoDB {table_name}")

    def __create_local_mode_table(self, table_name):
        if table_name not in [table.name for table in self.__dynamodb_resource.tables.all()]:
            print(" * Creating table")
            table = self.__dynamodb_resource.create_table(
                TableName=table_name,
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

    def get_user(self, name: str) -> User:
        """
        get_user retrieves user from dynamodb
        """
        # Ensure name is not empty
        if not User.is_valid_name(name):
            raise InvalidUsernameException()

        response = self.__table.get_item(Key={'name': name})

        if "Item" not in response:
            raise UserNotFoundException()

        return User(response['Item']['name'], response['Item']['birth_date'])

    def put_user(self, name: str, birth_date: str) -> User:
        """
        put_user stores user into dynamodb
        """
        user = User(name, birth_date)

        try:
            self.get_user(user.name)
            raise UserAlreadyExistsException()

        except UserNotFoundException:
            # User does not exist, add it
            self.__table.put_item(
                Item={
                    'name': user.name,
                    'birth_date': user.get_birth_date_str()
                }
            )
            return user

    def is_healthy(self) -> bool:
        """
        healthcheck test connection to DynamoDB health
        """
        try:
            response = self.__dynamodb_client.describe_table(TableName = self.__table.name)
            return response is not None
        except Exception:
            return False



