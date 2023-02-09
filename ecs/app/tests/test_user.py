# pylint: disable=missing-class-docstring 
# pylint: disable=missing-module-docstring 
# pylint: disable=missing-function-docstring
import unittest

from src.user import User


class UserTestCases(unittest.TestCase):

    def test_correct_user_name_and_correct_syntax_birth_date(self):
        User("adrian", "1989-03-07")
        User("adrian", "1989-03-30")

    def test_correct_user_name_and_correct_syntax_birth_date_but_its_in_the_future(self):
        with self.assertRaises(Exception):
            User("adrian", "3000-03-07")

    def test_correct_user_name_and_incorrect_birth_date(self):
        with self.assertRaises(Exception):
            User("adrian", "2500/03/07")

        with self.assertRaises(Exception):
            User("adrian", "1989/03/07")

        with self.assertRaises(Exception):
            User("adrian", "")

        with self.assertRaises(Exception):
            User("adrian", None)

        with self.assertRaises(Exception):
            User("adrian", 25)

    def test_incorrect_user_name_and_correct_birth_date(self):
        with self.assertRaises(Exception):
            User("adrian01", "1989/03/07")

        with self.assertRaises(Exception):
            User("adrian nieto", "1989/03/07")

        with self.assertRaises(Exception):
            User("adriannieper@gmail.com", "1989/03/07")
