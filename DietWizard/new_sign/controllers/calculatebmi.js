const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


// const product = require('../models/product');

exports.postcalculatebmi=async(req,res)=>{

    try {
        const { weight, height } = req.body;
          // console.log(weight, height);
        if (!weight || !height || weight <= 0 || height <= 0) {
          return res.status(400).json({ error: 'Weight and height must be positive values' });
        }
    
        const bmi = weight / ((height) * (height));
    
        let message;
        if (bmi < 18.5) {
          message = 'Underweight';
        } else if (bmi >= 18.5 && bmi < 25) {
          message = 'Normal weight';
        } else if (bmi >= 25 && bmi < 30) {
          message = 'Overweight';
        } else {
          message = 'Obese';
        }
    
        return res.status(200).json({ bmi, message });
      } catch (error) {
        console.error('Error:', error);
        return res.status(500).json({ error: 'Internal server error' });
      }
};
