from flask import Flask, request, jsonify
import numpy as np
import joblib
import pandas as pd
from datetime import datetime
import math
from pathlib import Path

app = Flask(__name__)

# ---------------------------------------------------------
# ✅ PATH SETUP 
# ---------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent 

DATA_DIR = BASE_DIR / "datasets"            

MODEL_DIR = BASE_DIR                    
 
# ---------------------------------------------------------
# ✅ LOAD ALL DATASETS 
# ---------------------------------------------------------

DATASETS = {
    "onion": DATA_DIR / "onion_2005_to_2025_pune.csv",
    "potato": DATA_DIR / "Agmarknet_Price_Report_Potato_2005to2025.csv",
    "rice": DATA_DIR / "Agmarknet_Price_Report_Rice_2005to2025.csv",
    "cucumber": DATA_DIR / "Cucumber_Price.csv"
}

DATA_FRAMES = {}
for veg, path in DATASETS.items():

    if not path.exists():
        raise FileNotFoundError(f"❌ Dataset not found: {path}")

    df = pd.read_csv(path)
    df["Date"] = pd.to_datetime(df["Price Date"], errors="coerce")
    DATA_FRAMES[veg] = df

# ---------------------------------------------------------
# ✅ LOAD MODELS 
# ---------------------------------------------------------

def load_model(veg):
    file_path = MODEL_DIR / f"{veg}_model.pkl"   
    if file_path.exists():
        return joblib.load(file_path)
    return None

# ---------------------------------------------------------
# ✅ SEASONAL MAX PRICE CALCULATION
# ---------------------------------------------------------

def get_dynamic_max_price(veg):
    df = DATA_FRAMES.get(veg)
    if df is None:
        return None

    df = df.dropna(subset=["Date", "Max Price (Rs./Quintal)"])

    today = datetime.now()
    day_now = today.day
    month_now = today.month

    df["day"] = df["Date"].dt.day
    df["month"] = df["Date"].dt.month

    df["distance"] = abs((df["month"] - month_now) * 31 + (df["day"] - day_now))

    closest_days = df[df["distance"] <= 3]

    if len(closest_days) == 0:
        return None

    prices = closest_days["Max Price (Rs./Quintal)"].dropna()
    cutoff = prices.quantile(0.95)
    cleaned = prices[prices <= cutoff]

    return float(cleaned.median())

# ---------------------------------------------------------
# ✅ PREPROCESS INPUT
# ---------------------------------------------------------

def preprocess_input(max_price):
    today = datetime.now()
    year = today.year
    month = today.month

    month_sin = math.sin(2 * math.pi * (month / 12))
    month_cos = math.cos(2 * math.pi * (month / 12))

    return np.array([[max_price, year, month_sin, month_cos]])

# ---------------------------------------------------------
# ✅ API ENDPOINT
# ---------------------------------------------------------

@app.route("/predict_price", methods=["POST"])
def predict_price():
    data = request.get_json()
    veg = data.get("vegetable").lower()

    model = load_model(veg)
    if model is None:
        return jsonify({"error": f"Model for '{veg}' not found"}), 404

    dynamic_max = get_dynamic_max_price(veg)
    if dynamic_max is None:
        return jsonify({"error": "Not enough seasonal data"}), 500

    scaler_path = MODEL_DIR / "scalar.pkl"

    if not scaler_path.exists():
        return jsonify({"error": "Scaler not found"}), 500

    scaler = joblib.load(scaler_path)

    scaled_max_price = scaler.transform([[dynamic_max]])[0][0]
    input_features = preprocess_input(scaled_max_price)

    predicted = model.predict(input_features)[0]

    return jsonify({
        "vegetable": veg,
        "predicted_modal_price": float(predicted),
        "max_price_used_for_prediction": dynamic_max,
        "date_used": datetime.now().strftime("%Y-%m-%d")
    })

# ---------------------------------------------------------
# ✅ RUN FLASK (DOCKER READY)
# ---------------------------------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
