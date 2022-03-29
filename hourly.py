import requests
response = requests.get("https://api.weather.gov/gridpoints/SEW/122,66/forecast/hourly")
periods = response.json()['properties']['periods']
for i in range(0, 24):
    period = periods[i]
    i = period['startTime'][11:16]
    t = f"{period['temperature']} {period['temperatureUnit']}"
    f = period["shortForecast"]
    print(f"{i}: {f} @ {t}")