class AppException(Exception):
    pass


class InvalidUsernameException(AppException):
    def __init__(self):
        super().__init__("Invalid user name")


class UserNotFoundException(AppException):
    def __init__(self):
        super().__init__("User not found")


class UserAlreadyExistsException(AppException):
    def __init__(self):
        super().__init__("User already exists")


class InvalidBirthDateException(AppException):
    def __init__(self):
        super().__init__("Invalid birth date")
