const express = require('express');
const router = express.Router();
const path = require('path');

const Exercise = require('../models/exerciseSchema');
const Category_exercises = require('../models/Category_exercise');
// // Route to render exercises.ejs with pagination

exports.getCategoryExercise = async (req, res) => {
    try {
 
        res.render('addexercises.ejs');
    } catch (error) {
      console.error('Error fetching exercises:', error);
      res.status(500).send('Server Error');
    }
  };



exports.postCategoryExercise = async (req, res) => {
    try {
        // Find the document in the database based on the type
        let categoryExercise = await Category_exercises.findOne({ type: req.body.type });
  
        // If document is found, update the numbers array
        if (categoryExercise) {
            const newNumbers = req.body.numbers.split(',').map(num => parseInt(num.trim()));
            
  
            // Filter out numbers that are already present in the array
            const numbersToAdd = newNumbers.filter(num => !categoryExercise.numbers.includes(num));
            
            // Add only the new numbers to the array
            categoryExercise.numbers = categoryExercise.numbers.concat(numbersToAdd);
  
            // Save the updated document
            await categoryExercise.save();
        } else {
            // Create new category exercise document if not found
            categoryExercise = new Category_exercises({
                type: req.body.type,
                numbers: req.body.numbers.split(',').map(num => parseInt(num.trim()))
            });
  
            // Save the new document to the database
            await categoryExercise.save();
        }
  
        // Redirect to a success page or any other page as needed
        res.render('addexercises.ejs');
    } catch (error) {
        // Handle error
        console.error(error);
        res.status(500).send('Internal Server Error');
    }
  };

