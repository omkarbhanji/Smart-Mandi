import { Market } from "../model/index.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { AppError } from "../utils/appError.js";
import axios from "axios";

// export const nearByPrices = asyncHandler(async (req, res, next) => {
//   const { state, district, crop, variety, grade, priceDate } = req.body;

//   if (!crop || !district || !state) {
//     return next(new AppError("Please enter all required fields", 400));
//   }

//   // 1. find nearby markets
//   const markets = await Market.findAll({
//     where: { district, state },
//     raw: true,
//   });

//   const queries = markets.map((m) => ({
//     state: m.state,
//     district: m.district,
//     market: m.name,
//     crop,
//     variety,
//     grade,
//     priceDate,
//   }));

//   const tasks = queries.map(async (q) => {
//     try {
//       const response = await axios.post("http://127.0.0.1:5000/predict", q);
//       return {
//         market: q.market,
//         predictedPrice: response.data.predicted_price,
//       };
//     } catch (err) {
//       return {
//         market: q.market,
//         error: "ML service unavailable",
//       };
//     }
//   });

//   const results = await Promise.all(tasks);

//   res.status(200).json({
//     status: "success",
//     crop,
//     count: results.length,
//     markets: results,
//   });
// });

export const nearByPrices = asyncHandler(async (req, res, next) => {
  const { state, district, crop, variety, grade, priceDate } = req.body;

  if (!crop || !district || !state || !priceDate) {
    return next(new AppError("Please enter all required fields", 400));
  }

  // Convert priceDate to day, month, year
  const dateObj = new Date(priceDate); // e.g., "2025-09-24"
  const day = dateObj.getDate();
  const month = dateObj.getMonth() + 1; // months are 0-based
  const year = dateObj.getFullYear();

  // 1. find nearby markets
  const markets = await Market.findAll({
    where: { district, state },
    raw: true,
  });

  const queries = markets.map((m) => ({
    state: m.state,
    district: m.district,
    market: m.name,
    crop,
    variety,
    grade,
    day,
    month,
    year,
  }));

  const tasks = queries.map(async (q) => {
    try {
      const response = await axios.post("http://127.0.0.1:5000/predict", q);
      return {
        market: q.market,
        predictedPrice: response.data.predicted_price,
      };
    } catch (err) {
      return {
        market: q.market,
        error: "ML service unavailable",
      };
    }
  });

  const results = await Promise.all(tasks);

  res.status(200).json({
    status: "success",
    crop,
    count: results.length,
    markets: results,
  });
});
