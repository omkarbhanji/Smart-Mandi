from flask import Flask, request, jsonify
import numpy as np
import joblib
import pandas as pd
from datetime import datetime
import math
import os
from pathlib import Path

app = Flask(__name__)

# ---------------------------------------------------------
# Load all datasets for dynamic max price calculation
# ---------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent
# print("BAse dir. path is : ", BASE_DIR)
DATA_DIR = BASE_DIR 


DATASETS = {
    "onion": DATA_DIR/ "datasets" / "onion_2005_to_2025_pune.csv",
    "potato": DATA_DIR / "datasets" / "Agmarknet_Price_Report_Potato_2005to2025.csv",
    "rice": DATA_DIR / "datasets"/  "Agmarknet_Price_Report_Rice_2005to2025.csv",
    "cucumber": DATA_DIR / "datasets" / "Cucumber_Price.csv"
}

DATA_FRAMES = {}
for veg, path in DATASETS.items():
    # print("Path is : ", path);
    df = pd.read_csv(path)
    # print("Columns:", list(df.columns))

    df["Date"] = pd.to_datetime(df["Price Date"], errors="coerce")
    DATA_FRAMES[veg] = df

# ---------------------------------------------------------
# Load models directory
# ---------------------------------------------------------
MODEL_DIR = DATA_DIR / "ml_model"

def load_model(veg):
    file_path = os.path.join(MODEL_DIR, f"{veg}_model.pkl")
    if os.path.exists(file_path):
        return joblib.load(file_path)
    return None

# ---------------------------------------------------------
# Seasonal Max Price Calculation (NEW LOGIC)
# ---------------------------------------------------------
def get_dynamic_max_price(veg):
    df = DATA_FRAMES.get(veg)
    if df is None:
        return None

    # Clean missing
    df = df.dropna(subset=["Date", "Max Price (Rs./Quintal)"])

    today = datetime.now()
    day_now = today.day
    month_now = today.month

    # Compute date-distance for every row (seasonal matching ignoring year)
    df["day"] = df["Date"].dt.day
    df["month"] = df["Date"].dt.month

    df["distance"] = abs((df["month"] - month_now) * 31 + (df["day"] - day_now))

    # Take closest ±3 seasonal days across years
    closest_days = df[df["distance"] <= 3]

    if len(closest_days) == 0:
        return None

    prices = closest_days["Max Price (Rs./Quintal)"].dropna()

    # Remove extreme spikes (top 5%)
    cutoff = prices.quantile(0.95)
    cleaned = prices[prices <= cutoff]

    return float(cleaned.median())


# ---------------------------------------------------------
# Preprocessing must match training feature order
# ---------------------------------------------------------
def preprocess_input(max_price, variety="Local"):
    today = datetime.now()
    year = today.year
    month = today.month

    month_sin = math.sin(2 * math.pi * (month / 12))
    month_cos = math.cos(2 * math.pi * (month / 12))

    # Convert variety to model-compatible column
    #variety_local = 1 if variety.lower() == "local" else 0

    # MUST match model.feature_names_in_
    return np.array([[max_price, year, month_sin, month_cos]])


# ---------------------------------------------------------
# API Endpoint
# ---------------------------------------------------------
@app.route("/predict_price", methods=["POST"])
def predict_price():
    data = request.get_json()

    veg = data.get("vegetable").lower()

    model = load_model(veg)
    if model is None:
        return jsonify({"error": f"Model for '{veg}' not found"}), 404

    # Compute dynamic max price (no hardcoding)
    dynamic_max = get_dynamic_max_price(veg)
    if dynamic_max is None:
        return jsonify({"error": "Not enough data for this month's seasonal estimation"}), 500

    

    scaler_path = MODEL_DIR / "temp2.pkl"

    if not os.path.exists(scaler_path):
        return jsonify({"error": "Scaler not found"}), 500
    
    scaler = joblib.load(scaler_path)
    tempp = dynamic_max
    # Scale the dynamic_max value
    scaled_max_price = scaler.transform([[dynamic_max]])[0][0]

    # Preprocess for ML model
    input_features = preprocess_input(
    # tempp,
    scaled_max_price,
    #variety=data.get("variety", "Local")
    )
    

    # Predict
    predicted = model.predict(input_features)[0]

    return jsonify({
        "vegetable": veg,
        "predicted_modal_price": float(predicted),
        "max_price_used_for_prediction": dynamic_max,
        "date_used": datetime.now().strftime("%Y-%m-%d")
    })


# ---------------------------------------------------------
# Run Flask
# ---------------------------------------------------------
if __name__ == "__main__":
    app.run(debug=True)