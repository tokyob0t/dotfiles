#!/usr/bin/python

import datetime
from sys import argv as args
import json


year, month, day, weekday, weekday_of_month_first = 0, 0, 0, 0, 0
days_in_month, days_in_last_month, days_in_next_month = 0, 0, 0
leap_year = False
highlight = True

calendar = [[0 for _ in range(7)] for _ in range(6)]
today = [[0 for _ in range(7)] for _ in range(6)]


def get_time():
    global year, month, day, weekday, weekday_of_month_first
    now = datetime.datetime.now()
    year, month, day = now.year, now.month, now.day
    weekday = (now.weekday() - 1) % 7
    weekday_of_month_first = (weekday + 36 - (day - 1)) % 7

def set_time(wd, d, m, y):
    global weekday, highlight, year, month, day, weekday_of_month_first
    wd -= 1
    highlight = False
    year, month, day = y, m, d
    weekday = (wd + 1) % 7
    weekday_of_month_first = (weekday + 35 - (day - 1)) % 7

def check_leap_year():
    global leap_year
    leap_year = year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)


def get_month_days():
    global days_in_month, days_in_last_month, days_in_next_month
    if (month <= 7 and month % 2 == 1) or (month >= 8 and month % 2 == 0):
        days_in_month = 31
    elif month == 2 and leap_year:
        days_in_month = 29
    elif month == 2 and not leap_year:
        days_in_month = 28
    else:
        days_in_month = 30
    if month == 1 and leap_year:
        days_in_next_month = 29
    elif month == 1 and not leap_year:
        days_in_next_month = 28
    elif (month <= 7 and month % 2 == 1) or (month >= 8 and month % 2 == 0):
        days_in_next_month = 30
    else:
        days_in_next_month = 31
    if month == 3 and leap_year:
        days_in_last_month = 29
    elif month == 3 and not leap_year:
        days_in_last_month = 28
    elif (month <= 7 and month % 2 == 1) or (month >= 8 and month % 2 == 0):
        days_in_last_month = 30
    else:
        days_in_last_month = 31


def calc_calendar():
    global calendar, today
    month_diff = 0 if weekday_of_month_first == 0 else -1
    dim = days_in_last_month
    i, j = 0, 0
    to_fill = 1 if weekday_of_month_first == 0 else (days_in_last_month - (weekday_of_month_first - 1))

    while i < 6 and j < 7:
        calendar[i][j] = to_fill
        if to_fill == day and month_diff == 0 and highlight:
            today[i][j] = 1
        elif month_diff == 0:
            today[i][j] = 0
        else:
            today[i][j] = -1
        to_fill += 1
        if to_fill > dim:
            month_diff += 1
            if month_diff == 0:
                dim = days_in_month
            elif month_diff == 1:
                dim = days_in_next_month
            to_fill = 1
        j += 1
        if j == 7:
            j = 0
            i += 1


def print_calendar():
    global calendar, today
    print(json.dumps([[{"day": calendar[i][j], "today": today[i][j]} for j in range(7)] for i in range(6)]))


if __name__ == "__main__":
    if len(args) == 1:
        get_time()
    elif len(args) == 5:
        set_time(int(args[1]), int(args[2]), int(args[3]), int(args[4]))
    else:
        print("./getCalendar to get a calendar for today")
        print("./getCalendar <weekday> <day> <month> <year> to get a calendar of the specified day")
    check_leap_year()
    get_month_days()
    calc_calendar()
    print_calendar()
