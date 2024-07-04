
const express = require('express');
const router = express.Router();
const path = require('path');
const Recipe =require('../models/RecipeSchema');


exports.getAllRecipeMobile = async (req, res) => {
    try {
     const recipes = await Recipe.find();
     res.json(recipes);
    } catch (error) {
     res.status(500).json({ error: 'Failed to fetch recipes' });
    }
};


exports.getRecipeMobile = async (req, res) => {
    try {
        let recipes;
        
        // Check if the request query contains 'foodName' parameter
        if (req.query.foodName) {
          // Use regex to find recipes with name containing the provided foodName
          recipes = await Recipe.find({ name: { $regex: req.query.foodName, $options: 'i' } });
        } else {
          // If no foodName parameter provided, return all recipes
          recipes = await Recipe.find();
        }
        
        res.json(recipes);
      } catch (err) {
        console.error('Error fetching recipes:', err);
        res.status(500).send('Internal Server Error');
      }
};
 