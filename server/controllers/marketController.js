const express = require('express');
const pool = require('../db');

exports.nearByPrices = async (req, res) => {
 

//     {
//   "state": "Kerala",
//   "district": "Kottayam",
//   "market_name": "Thalayolaparambu",
//   "commodity": "Onion",
//   "variety": "Big",
//   "grade": "FAQ",
//   "price_date": "2025-09-01"
// }

// GET /markets/nearby-prices?lat=..&lon=..&radius=..&commodity=Onion&variety=Big&grade=FAQ

//     /predict/price
//     /predict/distribution

//    STATE	 District Name	Market Name	Commodity	Variety	Grade	Min_Price	Max_Price	Modal_Price	Price Date


try{
      const {item, variety = null, grade = null, state, district, price_date} = req.query;

      if(!item || !district || !state){
        return res.status(400).json({message: "item name, district or state missing"});
      }

    //   1.  finding nearby markets -> i.e. markets in the city

    const {rows: markets} = await pool.query(
        `select name from markets where district= $1 and state = $2;`, [district, state]
    );

    // 2. for each market, calling the ML model

    const tasks = markets.map(async (m) => {
        const payload = {
            state: state || m.state,
            district: district || m.district,
            market_name: m.market_name,
            item,
            variety,
            grade,
            price_date
        };

        try{
        const [pt, dist] = await Promise.all([
          predictPrice(payload),
          predictDistribution(payload)
        ]);

        return {
            market_id: m.market_id,
          market_name: m.name,
          state: m.state,
          district: m.district,
          distance_km: Number(m.distance_km.toFixed(2)),
          predicted_price: pt.predicted_price,
          distribution: dist
        };
        }
        catch(err){
        return {
          market_id: m.market_id,
          market_name: m.name,
          state: m.state,
          district: m.district,
          distance_km: Number(m.distance_km.toFixed(2)),
          error: "ML service unavailable"
        };
        }
    });

    const results = await Promise.all(tasks);
    return res.json({
        item, 
        count: results.length,
        markets: results
    });


}catch(err){
    return res.status(500).json({ error: err.message });
}



   

};