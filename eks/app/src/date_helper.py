from datetime import datetime


class DateHelper:

    @staticmethod
    def days_until_next_occurence_of(given_date: datetime) -> int:
        """
        days_until_next_occurence_of calculates the amount of days between today (DD/MM) at 00:00 
        and the next ocurence of given date DD/MM
        """
        today = datetime.today()

        # Unify today date to remove delta between hh:mm:ss to avoid calculation mistakes
        today = datetime(today.year, today.month, today.day)

        # Unify given_date date to remove delta between hh:mm:ss to avoid calculation mistakes
        given_date = datetime(today.year, given_date.month, given_date.day)

        # If your already had your birthday this year, count to next year
        if given_date < today:
            given_date = given_date.replace(year=today.year + 1)

        return abs(given_date-today).days
