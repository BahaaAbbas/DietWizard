const express = require('express');

const router = express.Router();
const path = require('path');

const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices = require('../models/userChoices');
const waterintake = require('../models/Waterintake');
const progressphoto = require('../models/progressphotos');
const customfoodexe = require('../models/CustomFoodExe');
const diaryinfo = require('../models/Diaryinfo');
const historicaldiary = require('../models/historicalDiary');
const dailytrackprogress = require('../models/DailyTrackProgress');
const Coach = require('../models/coach'); 
const coachrating = require('../models/CoachRating');
const coachesListUser = require('../models/CoachesListUser'); // Adjust the path as necessary

const fs = require('fs');
const multer = require('multer');


exports.canRatingOrNOT = async (req, res) => {
  try {
    const email = req.body.email;

    // Find a coach where the given email belongs to a trainee
    const coach = await coachesListUser.findOne({ "coach.traineeEmail": email });

    if (!coach) {
      // If no coach found with the given trainee email
      return res.status(200).json({ message: 'no belongs' });
    }

    // Find the specific trainee information
    const trainee = coach.coach.find(trainee => trainee.traineeEmail === email);

    // If the trainee is found, return the response with coach and trainee information
    if (trainee) {
      return res.status(200).json({
        message: 'belong to coach',
        coachemail: coach.coachemail,
        traineeEmail: trainee.traineeEmail
      });
    }

    // If the email is not a trainee for any coach
    return res.status(200).json({ message: 'no belongs' });
  } catch (error) {
    console.error('Error in canRatingOrNOT:', error);
    return res.status(500).json({ message: 'Internal server error.' });
  }
};



exports.rateCoach = async (req, res) => {
    const { coachemail, traineeEmail, rating } = req.body;
    console.log("RateCoach");
    try {
      // Check if the coach exists in the coachrating collection
      let coachRating = await coachrating.findOne({ coachemail });
  
      if (!coachRating) {
        // Coach not found
        return res.status(404).json({ message: 'Coach not found' });
      }
  
      // Find the trainee in the coach's rating document
      let traineeIndex = coachRating.trainees.findIndex(
        (trainee) => trainee.traineeEmail === traineeEmail
      );
  
      if (traineeIndex !== -1) {
        // Update the existing rating for the trainee
        coachRating.trainees[traineeIndex].traineeRate = rating;
      } else {
        // Add a new rating for the trainee
        coachRating.trainees.push({ traineeEmail, traineeRate: rating });
      }
  
      // Update the currentRate and NumOfRates
      let totalRating = coachRating.trainees.reduce(
        (sum, trainee) => sum + parseFloat(trainee.traineeRate),
        0
      );
      coachRating.NumOfRates = coachRating.trainees.length.toString();
      coachRating.currentRate = (totalRating / coachRating.trainees.length).toFixed(2);
  
      // Save the updated coach rating
      await coachRating.save();
  
      return res.status(200).json({ message: 'Rating submitted successfully' });
    } catch (error) {
      console.error('Error rating coach:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  };

  
  exports.INFOrateCoaches = async (req, res) => {
    try {
      const coachRatings = await coachrating.find({}); // Fetch all coaches ratings
  
      return res.status(200).json(coachRatings);
    } catch (error) {
      console.error('Error fetching coaches ratings:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  };

  

  exports.FilterByNumRates = async (req, res) => {
    try {
     
      let coaches = await coachrating.find();
  
     
      coaches.sort((a, b) => parseInt(b.NumOfRates) - parseInt(a.NumOfRates));
  
      
      res.status(200).json(coaches);
    } catch (error) {
     
      res.status(500).json({ message: 'Error fetching coaches', error });
    }
  };

  exports.FilterByHighestRating = async (req, res) => {
    try {
      
      let coaches = await coachrating.find();
  
     
      coaches.sort((a, b) => parseFloat(b.currentRate) - parseFloat(a.currentRate));
  

      res.status(200).json(coaches);
    } catch (error) {

      res.status(500).json({ message: 'Error fetching coaches', error });
    }
  };
