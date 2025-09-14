// const { Market } = require("../model/index");
// const { predictPrice, predictDistribution } = require("../services");

import {Market} from "../model/index";
import {predictPrice, predictDistribution} from "../services";

exports.nearByPrices = async (req, res) => {
  try {
    const { item, variety = null, grade = null, state, district, priceDate } = req.query;

    if (!item || !district || !state) {
      return res
        .status(400)
        .json({ message: "item name, district or state missing" });
    }

    // 1. find nearby markets
    const markets = await Market.findAll({
      where: { district, state },
      raw: true,
    });

    // 2. for each market, call ML model
    const tasks = markets.map(async (m) => {
      const payload = {
        state: m.state,
        district: m.district,
        marketName: m.name,
        item,
        variety,
        grade,
        priceDate,
      };

      try {
        const [pt, dist] = await Promise.all([
          predictPrice(payload),
          predictDistribution(payload),
        ]);

        return {
          marketId: m.marketId,
          marketName: m.name,
          state: m.state,
          district: m.district,
          // distance_km depends on how you're computing distance (not in your schema)
          predictedPrice: pt.predictedPrice,
          distribution: dist,
        };
      } catch (err) {
        return {
          marketId: m.marketId,
          marketName: m.name,
          state: m.state,
          district: m.district,
          error: "ML service unavailable",
        };
      }
    });

    const results = await Promise.all(tasks);

    return res.json({
      item,
      count: results.length,
      markets: results,
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
