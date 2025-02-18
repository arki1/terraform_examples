from flask import Flask, request
import datetime
import os

app = Flask(__name__)

# ANSI color codes
COLOR_CODES = {
    "red": "\033[31m",
    "pink": "\033[35m",
    "green": "\033[32m",
    "blue": "\033[34m",
    "orange": "\033[33m",
    "gray": "\033[90m",
    "reset": "\033[0m"
}

@app.route("/")
def hello():
    current_time = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    current_region = os.getenv("GOOGLE_CLOUD_REGION", "unknown region")
    background_color = "white"
    region_number = 0

    if current_region == "us-central1":
        background_color = "red"
        region_number = 1
    elif current_region == "us-east1":
        background_color = "pink"
        region_number = 2
    elif current_region == "southamerica-east1":
        background_color = "green"
        region_number = 3
    elif current_region == "southamerica-west1":
        background_color = "blue"
        region_number = 4
    elif current_region == "europe-west1":
        background_color = "orange"
        region_number = 5
    elif current_region == "northamerica-northeast1":
        background_color = "gray"
        region_number = 6

    # Determine if a region should be unavailable
    minutes_since_midnight = (datetime.datetime.utcnow() - datetime.datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)).total_seconds() // 60
    result = minutes_since_midnight % 6

    if region_number == result:
        return "503 Service Unavailable", 503

    # Detect if the request is coming from curl
    user_agent = request.headers.get("User-Agent", "").lower()
    is_curl = "curl" in user_agent

    if is_curl:
        color_code = COLOR_CODES.get(background_color, COLOR_CODES["reset"])
        return f"{color_code}Hello World! {current_time} {current_region}{COLOR_CODES['reset']}\n"

    return f"<html><head><title>{current_region}</title></head><body style='background-color: {background_color}'>Hello World! {current_time} {current_region}</body></html>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
