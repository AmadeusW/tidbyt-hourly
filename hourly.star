load("render.star", "render")
load("http.star", "http")
load("cache.star", "cache")

SEATTLE_WEATHER_URL = "https://api.weather.gov/gridpoints/SEW/122,66/forecast/hourly"
CACHE_KEY = "seattle_weather"

colors = {
    "Mostly Sunny": "#fa3",
    "Partly Sunny": "#a80",
    "Partly Cloudy": "#a33",
    "Mostly Cloudy": "#388",
    "Slight Chance Rain Showers": "#88f",
    "Chance Rain Showers": "#44f",
    "Slight Chance Light Rain": "#88a",
    "Chance Light Rain": "#33a",
    "tick": "#333"
}

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
    graph = []
    ticks = []
    for i in range(0, 12):
        period = periods[i]
        i = period['startTime'][11:16]
        t = period['temperature'] # in fahrenheit
        f = period["shortForecast"]
        print("%s: %s @ %s F" % (i, f, t))

        # Make graph based on temperature
        graph.append(render.Box(width=3, height=int((int(t) - 30)/2), color = colors[f]))

        # Make ticks based on time
        tickWidth = 1
        tickHeight = 1
        if (i[0:2] == "12"):
          tickWidth = 3
          tickHeight = 2
        elif (i[0:2] == "06"):
          tickHeight = 2
        elif (i[0:2] == "18"):
          tickHeight = 2

        ticks.append(render.Box(width=tickWidth, height=tickHeight, color = colors["tick"]))

    return render.Root(
        child = render.Column(
            main_align = "end",
            expanded = True,
            children = [
                render.Row(
                    expanded = True,
                    main_align = "space_evenly",
                    cross_align = "end",
                    children = graph
                    #children = [
                        #render.Text(forecast),
                    #],
                ),
                render.Row(
                    expanded = True,
                    main_align = "space_evenly",
                    cross_align = "end",
                    children = ticks
                ),
            ],
        ),
    )