// const { Farmer } = require("../model/index"); 
import {Farmer} from "../model/index.js"; 
// Register user
export const registerUser = async (req, res) => {
  const {
    name,
    email,
    password,
    phone,
    location,
    state,
    latitude,
    longitude,
  } = req.body;

  try {
    await Farmer.create({
      name,
      email,
      password,
      phone,
      location,
      state,
      latitude,
      longitude,
    });

    return res
      .status(201)
      .json({ message: "User created successfully" });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

// Login user
export const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const farmer = await Farmer.findOne({ where: { email } });

    if (!farmer) {
      return res.status(400).json({ message: "User not found!" });
    }

    if (farmer.password !== password) {
      return res
        .status(401)
        .json({ message: "Invalid credentials, password didn't match" });
    }

    return res.status(200).json({ message: "Login success" });
  } catch (err) {
    return res
      .status(500)
      .json({ message: "Internal Server Error", error: err.message });
  }
};
