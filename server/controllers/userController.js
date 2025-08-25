const express = require('express');
const pool = require('../db');


//json remaining


exports.registerUser = async(req, res) => {
    const name = req.body.name;
    const email = req.body.email;
    const password = req.body.password;
    const phone = req.body.phone;
    const location = req.body.location;
    const state = req.body.state;
    const latitude = req.body.latitude;
    const longitude = req.body.longitude;

    try{
        const response = await pool.query(`insert into farmers
             (name, email, password, phone, location, state, latitude, longitude) 
             values ('${name}', '${email}', '${password}', '${phone}', 
             '${location}', '${state}', '${latitude}', '${longitude}');
             `);

             return res.status(201).json({message: "User created successfully/"});
    }
    catch(err){
        return res.status(500).json({error: err.message});
    }
};

exports.loginUser = async (req, res) => {
    const email = req.body.email;
    const password = req.body.password;
    try{
        const response = await pool.query(`select * from farmers where email = $1`, [email]);
        if(response.rowCount === 0){
        res.status(400).json({message: 'user not found !'});
      }

       if(response.rows[0].password != password){
        return res.status(401).json({message: "Invalid credentials, password didnt match"});
      }

      if(response.rows[0].password == password){
        
        return res.status(200).json({message: "login success"});
      }



    }catch(err){
        return res.status(500).json({message: 'Internal Server error', error: err.message});
    }   

};