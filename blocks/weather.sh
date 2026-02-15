#!/bin/bash

# weather display in bar with open-meteo 
# weather browser display with bluemeteo

# dependency check: curl and jq
for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null; then
        echo "Weather: N/A"
        exit 0
    fi
done

########## QUERY LOCATION ##########
cache="$HOME/.config/i3blocks-unified/location.cache"
mkdir -p "$cache"

# if cache is there, but too old, update it, otherwise use it
if [ -f "$cache" ] && [ "$(find "$cache" -mmin -60 2>/dev/null)" ]; then
    # find lat and lon from cache
    source "$cache"
else
    # update the location cache with new coordinates
    geo="$(curl -fsS --max-time 5 https://ipapi.co/json/ || echo '')"

    new_lat="$(echo "$geo" | jq -r '.latitude // empty')" # extract values or 'empty' from json
    new_lon="$(echo "$geo" | jq -r '.longitude // empty')"
    new_city="$(echo "$geo" | jq -r '.city // empty')"
    new_country="$(echo "$geo" | jq -r '.country_name // empty')"

    # update the cache if we got new coordinates
    if [ -n "$new_lat" ] && [ -n "$new_lon" ]; then
        printf 'lat=%s\nlon=%s\ncity=%s\ncountry=%s\n' "$new_lat" "$new_lon" "$new_city" "$new_country" >"$cache"
        lat="$new_lat"
        lon="$new_lon"
        city="$new_city"
        country="$new_country"
    # if we got no coordinates, but there is a cache, fallback to still using the cache values
    elif [ -f "$cache" ]; then
        source "$cache"
    fi
fi

# no coordinates extracted, no wheather
if [ -z "$lat" ] || [ -z "$lon" ]; then
    echo "Weather: N/A (no location)"
    exit 0
fi

# make city and country save for usage inside of a URL
city_enc=$(jq -sRr @uri <<<"$city")  # read entire line at once as plain text and return as plain text
country_enc=$(jq -sRr @uri <<<"$country")

########## DISPLAY WHEATHER ##########

# query open-meteo for the weather
wx=$(curl -fsS --max-time 2 \
  "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,apparent_temperature,weather_code&timezone=auto" \
  || true)

# temperature
t=$(jq -r '.current.temperature_2m // empty' <<<"$wx")
# feels like temperature
t_feels=$(jq -r '.current.apparent_temperature // empty' <<<"$wx")
# weather code (for icon)
code=$(jq -r '.current.weather_code // empty' <<<"$wx")

if [ -z "$t" ] || [ -z "$code" ]; then
    echo "Weather: N/A (no weather)"
    exit 0
fi

# function to convert wheather codes into readible weather strings ("states")
state_from_code() {
  case "$1" in
    0) echo "Sunny" ;;
    1|2) echo "PartlyCloudy" ;;
    3) echo "Cloudy" ;;
    45|48) echo "Fog" ;;
    51|53|55) echo "LightRain" ;;
    61|63|65|80|81|82) echo "HeavyRain" ;;
    71|73|75|77|85|86) echo "HeavySnow" ;;
    95|96|99) echo "ThunderyShowers" ;;
    *) echo "Unknown" ;;
  esac
}

# function to convert states into emojis
emoji_from_state() {
  case "$1" in
    Unknown) echo "✨" ;;
    Cloudy|VeryCloudy) echo "☁️" ;;
    Fog) echo "🌫" ;;
    HeavyRain|HeavyShowers) echo "🌧" ;;
    HeavySnow|HeavySnowShowers) echo "❄️" ;;
    LightRain|LightShowers) echo "🌦" ;;
    LightSleet|LightSleetShowers) echo "🌧" ;;
    LightSnow) echo "🌨" ;;
    LightSnowShowers) echo "🌨" ;;
    PartlyCloudy) echo "⛅️" ;;
    Sunny) echo "☀️" ;;
    ThunderyHeavyRain) echo "🌩" ;;
    ThunderyShowers|ThunderySnowShowers) echo "⛈" ;;
  esac
}

# get current wheather state and emoji
state=$(state_from_code "$code")
icon=$(emoji_from_state "$state")

# output the city, country, weather emoji, temperature (feels: feels_temperature)
printf "%s, %s: %s %+.0f°C (feels %+.0f°C)\n" "$city" "$country" "$icon" "$t" "$t_feels"


########## WHEATHER PAGE ON CLICK ##########

# open a weather page if button is clicked
case "${BLOCK_BUTTON:-}" in
  1)
  	# if the xdg-utils exists (to use the standard browser)
    if command -v xdg-open >/dev/null; then

	      url="https://www.meteoblue.com/en/weather/week/${lat},${lon}"
	      # open page based on coordinates
	      xdg-open "$url" >/dev/null 2>&1 &
    fi
    ;;
esac



#### wttr.in alternative for the bar display: seemed too inaccurate 

# weather=$(curl -s "https://wttr.in/?format=%l:+%c+%t+(feels+%f)" | tr -d '\n')
# 
# if [ -z "$weather" ]; then
#     echo "N/A"
# else
#     # sanitize percent signs and quotes for i3bar
#     safe_weather=$(echo "$weather" | sed 's/%/%%/g; s/"/\\"/g')
#     echo "$safe_weather"
# fi
