# pylint: disable=missing-class-docstring 
# pylint: disable=missing-module-docstring 
# pylint: disable=missing-function-docstring
import calendar
import unittest
from datetime import datetime

from src.date_helper import DateHelper


class DateHelperTestCases(unittest.TestCase):

    def test_days_until_next_occurence_of_check_if_given_date_is_today(self):
        # pylint: disable=missing-function-docstring

        given_date = datetime.today()
        assert DateHelper().days_until_next_occurence_of(given_date) == 0


    def test_days_until_next_occurence_of_check_if_given_date_is_a_day_after_today(self):
        # pylint: disable=missing-function-docstring

        today = datetime.today()
        given_date = datetime(today.year, today.month, today.day + 1)
        assert DateHelper().days_until_next_occurence_of(given_date) == 1


    def test_days_until_next_occurence_of_check_if_given_date_is_a_day_before_today(self):
        # pylint: disable=missing-function-docstring

        today = datetime.today()
        given_date = datetime(today.year, today.month, today.day - 1)

        if calendar.isleap(today.year):
            assert DateHelper().days_until_next_occurence_of(given_date) == 365
        else:
            assert DateHelper().days_until_next_occurence_of(given_date) == 364
