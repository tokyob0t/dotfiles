import requests
from PotatoWidgets import Poll

from .config import WEATHER as WEATHER_KEYS

KEY = WEATHER_KEYS["KEY"]
ID = WEATHER_KEYS["ID"]
UNIT = WEATHER_KEYS["UNIT"]


default_weather = {
    "city": "Unknown City",
    "country": "Unknown Country",
    "icon": "weather-severe-alert-symbolic",
    "description": "Unavailable",
    "temperature": "0",
    "temperature_min": "0",
    "temperature_max": "0",
    "humidity": "0",
    "pressure": "0",
    "quoteOne": "Ah well, no weather huh?",
    "quoteTwo": "Even if there's no weather, it's gonna be a great day!",
    "hex": "#adadff",
}


def get_weather_icon(weather_icon_code):
    return {
        "01d": "weather-clear",
        "01n": "weather-clear-night",
        "02d": "weather-few-clouds",
        "02n": "weather-few-clouds-night",
        "03d": "weather-few-clouds",
        "03n": "weather-few-clouds-night",
        "04d": "weather-overcast",
        "04n": "weather-overcast",
        "09d": "weather-showers",
        "09n": "weather-showers",
        "10d": "weather-showers-scattered",
        "10n": "weather-showers-scattered",
        "11d": "weather-storm",
        "11n": "weather-storm",
        "13d": "weather-snow",
        "13n": "weather-snow",
        "50d": "weather-fog",
        "50n": "weather-fog",
    }.get(weather_icon_code, "weather-severe-alert") + "-symbolic"


def get_weather():
    url = f"http://api.openweathermap.org/data/2.5/weather?APPID={KEY}&id={ID}&units={UNIT}"
    try:
        weather = requests.get(url)
        if weather.status_code != 200:
            return default_weather
    except:
        return default_weather

    weather = weather.json()
    city = weather.get("name", "Unknown City")
    country = weather["sys"].get("country", "Unknown Country")

    weather_temp = int(weather["main"]["temp"])
    weather_icon_code = weather["weather"][0]["icon"]
    weather_description = weather["weather"][0]["description"].capitalize()
    weather_humidity = weather["main"]["humidity"]
    weather_tempMin = weather["main"]["temp_min"]
    weather_tempMax = weather["main"]["temp_max"]
    weather_pressure = weather["main"]["pressure"]

    weather_icon = get_weather_icon(weather_icon_code)

    weather_quote1 = ""
    weather_quote2 = ""
    weather_hex = ""

    if weather_icon_code in ["50d", "40d"]:
        weather_quote1 = "Forecast says it's misty"
        weather_quote2 = "Make sure you don't get lost on your way..."
        weather_hex = "#a7b8b2"
    elif weather_icon_code in ["50n", "40n"]:
        weather_quote1 = "Forecast says it's a misty night"
        weather_quote2 = "Don't go anywhere tonight or you might get lost..."
        weather_hex = "#84afdb"
    elif weather_icon_code == "01d":
        weather_quote1 = "It's a sunny day, gonna be fun!"
        weather_quote2 = "Don't go wandering all by yourself though..."
        weather_hex = "#ffd86b"
    elif weather_icon_code == "01n":
        weather_quote1 = "It's a clear night"
        weather_quote2 = "You might want to take an evening stroll to relax..."
        weather_hex = "#fcdcf6"
    elif weather_icon_code in ["02d", "03d", "04d"]:
        weather_quote1 = "It's cloudy, sort of gloomy"
        weather_quote2 = "You'd better get a book to read..."
        weather_hex = "#adadff"
    elif weather_icon_code in ["02n", "03n", "04n"]:
        weather_quote1 = "It's a cloudy night"
        weather_quote2 = "How about some hot chocolate and a warm bed?"
        weather_hex = "#adadff"
    elif weather_icon_code in ["09d", "10d"]:
        weather_quote1 = "It's rainy, it's a great day!"
        weather_quote2 = "Get some ramen and watch as the rain falls..."
        weather_hex = "#6b95ff"
    elif weather_icon_code in ["09n", "10n"]:
        weather_quote1 = "It's gonna rain tonight it seems"
        weather_quote2 = "Make sure your clothes aren't still outside..."
        weather_hex = "#6b95ff"
    elif weather_icon_code == "11d":
        weather_quote1 = "There's a storm forecast today"
        weather_quote2 = "Make sure you don't get blown away..."
        weather_hex = "#ffeb57"
    elif weather_icon_code == "11n":
        weather_quote1 = "There's gonna be storms tonight"
        weather_quote2 = "Make sure you're warm in bed and the windows are shut..."
        weather_hex = "#ffeb57"
    elif weather_icon_code == "13d":
        weather_quote1 = "It's gonna snow today"
        weather_quote2 = "You'd better wear thick clothes and make a snowman as well!"
        weather_hex = "#e3e6fc"
    elif weather_icon_code == "13n":
        weather_quote1 = "It's gonna snow tonight"
        weather_quote2 = "Make sure you get up early tomorrow to see the sights..."
        weather_hex = "#e3e6fc"

    else:
        weather_quote1 = "Sort of odd, I don't know what to forecast"
        weather_quote2 = "Make sure you have a good time!"
        weather_hex = "#adadff"

    weather_data = {
        "city": city,
        "country": country,
        "icon": weather_icon,
        "description": weather_description,
        "temperature": str(weather_temp),
        "temperature_min": str(weather_tempMin),
        "temperature_max": str(weather_tempMax),
        "humidity": str(weather_humidity),
        "pressure": str(weather_pressure),
        "quoteOne": weather_quote1,
        "quoteTwo": weather_quote2,
        "hex": weather_hex,
    }
    return weather_data


WEATHER = Poll("15m", get_weather, default_weather)
# WEATHER = Poll("15m", get_weather, get_weather())
