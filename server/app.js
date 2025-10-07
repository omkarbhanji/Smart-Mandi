import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import userRoutes from "./routes/userRoutes.js";
import inventoryRoutes from "./routes/inventoryRoutes.js";
import marketRoutes from "./routes/marketRoutes.js";
import { errorHandler } from "./middlewares/errorHandler.js";

const app = express();

app.use(cors());
app.use(express.json());
app.use(cookieParser());

// app.get("/", (req, res) => {
//   res.send("Server is working!");
// });

app.use("/api/users", userRoutes);
app.use("/api/inventory", inventoryRoutes);
app.use("/api/market", marketRoutes);

app.get("/ping", (req, res) => {
  console.log("req come");
  res.status(200).json({
    status: "success",
    message: "Pong , server up and running!!",
  });
});

app.use(errorHandler);

export default app;
