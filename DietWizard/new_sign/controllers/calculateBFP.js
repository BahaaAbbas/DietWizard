const express = require('express');
const router = express.Router();
const path = require('path');


// const product = require('../models/product');


function calculateBodyFatPercentage(weight, height, age, gender) {
    const bmi = weight / ((height / 100) * (height / 100));
  
    let bfpValue = 0;
    if (gender === 'male') {
        bfpValue = (1.20 * bmi) + (0.23 * age) - 16.2;
    } else if (gender === 'female') {
        bfpValue = (1.20 * bmi) + (0.23 * age) - 5.4;
    }
  
    return bfpValue;
  }


exports.postcalculateBFP=async(req,res)=>{

    const { weight, height, age, gender } = req.body;

  // Calculate Body Fat Percentage
  const bfp = calculateBodyFatPercentage(weight, height, age, gender);
  const roundedbfp = bfp.toFixed(2);  
  // Calculate fat mass based on body fat percentage
 

  const fatMass = weight * (bfp / 100);
  const roundedFatMass = fatMass.toFixed(2);


  // Calculate lean mass
  const leanMass = weight - fatMass;
  const roundedleanMass = leanMass.toFixed(2);


  // Determine description based on body fat percentage and gender
  let description;
  if (gender === "male") {
      if (bfp < 6) {
          description = "Essential Fat";
      } else if (bfp >= 6 && bfp < 14) {
          description = "Athletes";
      } else if (bfp >= 14 && bfp < 18) {
          description = "Fitness";
      } else if (bfp >= 18 && bfp < 25) {
          description = "Average";
      } else {
          description = "Obese";
      }
  } else { // Assuming female
      if (bfp < 14) {
          description = "Essential Fat";
      } else if (bfp >= 14 && bfp < 21) {
          description = "Athletes";
      } else if (bfp >= 21 && bfp < 25) {
          description = "Fitness";
      } else if (bfp >= 25 && bfp < 32) {
          description = "Average";
      } else {
          description = "Obese";
      }
  }

  // Send the calculated values as response
  res.json({ bfp: roundedbfp, fat_mass: roundedFatMass, lean_mass: roundedleanMass, description: description });
};
