from flask import Flask
import datetime
import os

app = Flask(__name__)

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

    # every minute, one of the regions will be unavailable

    # calculate the number of minutes since the beginning of the day
    minutes_since_midnight = (datetime.datetime.utcnow() - datetime.datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)).total_seconds() // 60

    # and find the division remainder of 6
    result = minutes_since_midnight % 6

    # if region equals result, returns a 503 error
    if region_number == result:
        return "503 Service Unavailable", 503

    return f"<html><head><title>{current_region}</title></head><body style='background-color: {background_color}'>Hello World! {current_time} {current_region}</body></html>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
