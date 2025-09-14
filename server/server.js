// const express = require('express');
// const cors = require('cors');
import express from "express";
import cors from "cors";
// const dotenv = require("dotenv");
import dotenv from "dotenv";
console.log("dotenv imported successfully");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// const userRoutes = require('./routes/userRoutes');
// const inventoryRoutes = require('./routes/inventoryRoutes');
import userRoutes from "./routes/userRoutes.js";
import inventoryRoutes from "./routes/inventoryRoutes.js";

app.get('/', (req, res) => {
  res.send('Server is working!');
});

app.use('/api/users', userRoutes);  
app.use('/api/inventory', inventoryRoutes);  
// app.use('/api/markets', marketRoutes);

const PORT = 5000;



app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});