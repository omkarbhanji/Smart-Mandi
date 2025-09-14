// const express = require('express');
import express from "express";
const router = express.Router();

// const {registerUser, loginUser} = require('../controllers/userController');
import {registerUser, loginUser} from "../controllers/userController.js";

router.post('/register', registerUser);  
router.post('/login', loginUser);  

export default router;