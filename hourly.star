load("render.star", "render")
load("http.star", "http")
load("cache.star", "cache")

SEATTLE_WEATHER_URL = "https://api.weather.gov/gridpoints/SEW/122,66/forecast/hourly"
CACHE_KEY = "seattle_weather"

def main():
    forecastCached = cache.get(CACHE_KEY)
    if forecastCached != None:
        print("Cache hit; Using cached data.")
        forecast = (forecastCached)
    else:
        print("Cache miss; Calling weather.gov API.")
        response = http.get(SEATTLE_WEATHER_URL)
        if response.status_code != 200:
            fail("Weather request failed with status %d", response.status_code)
        forecast = response.json()["properties"]["periods"][0]["shortForecast"]
        cache.set(CACHE_KEY, forecast, ttl_seconds = 600)

    periods = response.json()['properties']['periods']
    for i in range(0, 12):
        period = periods[i]
        i = period['startTime'][11:16]
        t = period['temperature'] # in fahrenheit
        f = period["shortForecast"]
        print("%s: %s @ %s F" % (i, f, t))

    return render.Root(
        child = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Text(forecast),
                ],
            ),
        ),
    )