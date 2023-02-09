import re
from datetime import datetime

from exceptions import InvalidBirthDateException, InvalidUsernameException


class User:

    __DATE_FORMAT = "%Y-%m-%d"

    __name_regex = re.compile(r"[a-zA-Z]+")

    @staticmethod
    def is_valid_name(name: str) -> bool:
        return re.fullmatch(User.__name_regex, name) is not None

    @staticmethod
    def is_valid_birth_date(birth_date: str) -> bool:
        try:
            date = datetime.strptime(birth_date, User.__DATE_FORMAT)
            return datetime.today() >= date
        except Exception:
            return False

    def get_birth_date_str(self) -> str:
        return self.birth_date.strftime(User.__DATE_FORMAT)

    def __init__(self, name: str, birth_date: str):
        if not User.is_valid_name(name):
            raise InvalidUsernameException()

        if not User.is_valid_birth_date(birth_date):
            raise InvalidBirthDateException()

        self.name = name
        self.birth_date = datetime.strptime(birth_date, "%Y-%m-%d")
