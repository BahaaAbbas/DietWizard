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

const fs = require('fs');
const multer = require('multer');






// exports.weightbyUSER = async (req, res) => {
//   try {
//     const email = req.body.email;

//     const userProgress = await historicaldiary.findOne({ email: email });

//     if (!userProgress || !userProgress.daydate || userProgress.daydate.length === 0) {
//       return res.status(404).json({ message: 'No progress data found for this user.' });
//     }

//     // Sort the daydate array by date in ascending order
//     userProgress.daydate.sort((a, b) => new Date(a.todaydate) - new Date(b.todaydate));

//     // Get today's date
//     const today = new Date().toISOString().split('T')[0];

//     // Create an array to store the weight data
//     let dataFOOD = [];

//     // Iterate over each entry to extract the date and current weight until today's date
//     userProgress.daydate.forEach(entry => {
//       if (new Date(entry.todaydate).toISOString().split('T')[0] <= today) {
//         const formattedWeight = parseFloat(entry.currentweight).toFixed(2);
//         dataFOOD.push({
//           date: new Date(entry.todaydate).toISOString().split('T')[0], // Format date to YYYY-MM-DD
//           weight: formattedWeight
//         });
//       }
//     });

//     return res.json(dataFOOD);
//   } catch (error) {
//     console.error('Error processing weightbyUSER request:', error);
//     return res.status(500).json({ message: 'Internal server error.' });
//   }
// }

exports.weightbyUSER = async (req, res) => {
  try {
    const email = req.body.email;

    const userProgress = await historicaldiary.findOne({ email: email });

    if (!userProgress || !userProgress.daydate || userProgress.daydate.length === 0) {
      return res.status(404).json({ message: 'No progress data found for this user.' });
    }

    // Sort the daydate array by date in ascending order
    userProgress.daydate.sort((a, b) => new Date(a.todaydate) - new Date(b.todaydate));

    // Get today's date
    const today = new Date().toISOString().split('T')[0];

    // Create an array to store the weight data
    let dataFOOD = [];

    // Variable to keep track of the last added weight
    let lastAddedWeight = null;

    // Iterate over each entry to extract the date and current weight until today's date
    userProgress.daydate.forEach(entry => {
      const entryDate = new Date(entry.todaydate).toISOString().split('T')[0];
      const formattedWeight = parseFloat(entry.currentweight).toFixed(2);

      if (entryDate <= today && formattedWeight !== lastAddedWeight) {
        dataFOOD.push({
          date: entryDate, // Format date to YYYY-MM-DD
          weight: formattedWeight
        });
        lastAddedWeight = formattedWeight;
      }
    });

    return res.json(dataFOOD);
  } catch (error) {
    console.error('Error processing weightbyUSER request:', error);
    return res.status(500).json({ message: 'Internal server error.' });
  }
}




 

// exports.weightFood = async (req, res) => {
//   try {
//     const email = req.body.email;
//     const userProgress = await dailytrackprogress.findOne({ email: email });

//     if (!userProgress || !userProgress.daydate || userProgress.daydate.length === 0) {
//       return res.status(404).json({ message: 'No progress data found for this user.' });
//     }

//     // Initialize the total burned calories and current weight
//     let totalBurnedCalories = 0;
//     let currentWeight = parseFloat(userProgress.daydate[0].currentweight); // Read initial weight

//     // Create an array to store the weight data
//     let dataFOOD = [];

//     // Iterate over each entry to calculate the cumulative weight change
//     userProgress.daydate.forEach(entry => {
//       if (entry.burned && entry.currentweight) {
//         totalBurnedCalories = parseFloat(entry.burned);
//         const weightChange = totalBurnedCalories / 7700; // 7700 calories per kg of fat
//         currentWeight = currentWeight - weightChange;
//         const formattedWeight = currentWeight.toFixed(2);

//         // Add each entry's date and calculated weight to the dataFOOD array
//         dataFOOD.push({
//           date: new Date(entry.todaydate).toISOString().split('T')[0], // Format date to YYYY-MM-DD
//           weight: formattedWeight
//         });
//       }
//     });

//     return res.json(dataFOOD);
//   } catch (error) {
//     console.error('Error processing weightFood request:', error);
//     return res.status(500).json({ message: 'Internal server error.' });
//   }
// }

exports.weightFood = async (req, res) => {
  try {
    const email = req.body.email;
    const userProgress = await dailytrackprogress.findOne({ email: email });

    if (!userProgress || !userProgress.daydate || userProgress.daydate.length === 0) {
      return res.status(404).json({ message: 'No progress data found for this user.' });
    }

    // Initialize the total burned calories and current weight
    let totalBurnedCalories = 0;
    let currentWeight = parseFloat(userProgress.daydate[0].currentweight); // Read initial weight

    // Create an array to store the weight data
    let dataFOOD = [];

    // Variable to keep track of the last added weight
    let lastAddedWeight = null;

    // Iterate over each entry to calculate the cumulative weight change
    userProgress.daydate.forEach(entry => {
      if (entry.burned && entry.currentweight) {
        totalBurnedCalories = parseFloat(entry.burned);
        const weightChange = totalBurnedCalories / 7700; // 7700 calories per kg of fat
        currentWeight = currentWeight - weightChange;
        const formattedWeight = currentWeight.toFixed(2);

        // Add each entry's date and calculated weight to the dataFOOD array if not a duplicate
        if (formattedWeight !== lastAddedWeight) {
          dataFOOD.push({
            date: new Date(entry.todaydate).toISOString().split('T')[0], // Format date to YYYY-MM-DD
            weight: formattedWeight
          });
          lastAddedWeight = formattedWeight;
        }
      }
    });

    return res.json(dataFOOD);
  } catch (error) {
    console.error('Error processing weightFood request:', error);
    return res.status(500).json({ message: 'Internal server error.' });
  }
}


// exports.buttonINFOCURRENT = async (req, res) => {
//   try {
//     const email = req.body.email;

//     // Find the user progress
//     const userProgress = await dailytrackprogress.findOne({ email: email });

//     if (!userProgress || !userProgress.daydate || userProgress.daydate.length === 0) {
//       return res.status(404).json({ message: 'No progress data found for this user.' });
//     }

//     // Find the user's height
//     const userChoice = await userChoices.findOne({ email: email });
//     if (!userChoice || !userChoice.height) {
//       return res.status(404).json({ message: 'Height data not found for this user.' });
//     }
//     const heightInMeters = parseFloat(userChoice.height) / 100; // Convert height from cm to meters

//     // Sort the daydate array by todaydate in ascending order
//     userProgress.daydate.sort((a, b) => new Date(a.todaydate) - new Date(b.todaydate));

//     // Get the first and last entry based on todaydate
//     const firstEntry = userProgress.daydate[0];
//     const lastEntry = userProgress.daydate[userProgress.daydate.length - 1];

//     // Calculate the current weights and the difference
//     const firstWeight = parseFloat(firstEntry.currentweight);
//     const lastWeight = parseFloat(lastEntry.currentweight);
//     const weightDifference = (lastWeight - firstWeight).toFixed(2);

//     // Calculate how many kg left to reach the goal weight
//     const goalWeight = parseFloat(lastEntry.goalWeight);
//     const kgLeftToGoal = (lastWeight - goalWeight).toFixed(2);

//     // Calculate BMI
//     const bmi = (lastWeight / (heightInMeters * heightInMeters)).toFixed(2);

//     return res.json({
//       firstEntryWeight: firstWeight.toFixed(2),
//       lastEntryWeight: lastWeight.toFixed(2),
//       weightDifference: weightDifference,
//       kgLeftToGoal: kgLeftToGoal,
//       bmi: bmi
//     });
//   } catch (error) {
//     console.error('Error processing buttonINFOCURRENT request:', error);
//     return res.status(500).json({ message: 'Internal server error.' });
//   }

// };

exports.buttonINFOCURRENT = async (req, res) => {
  try {
    const email = req.body.email;

    // Find the user progress
    const userProgress = await dailytrackprogress.findOne({ email: email });

    if (!userProgress || !userProgress.daydate || userProgress.daydate.length === 0) {
      return res.status(404).json({ message: 'No progress data found for this user.' });
    }

    // Find the user's height
    const userChoice = await userChoices.findOne({ email: email });
    if (!userChoice || !userChoice.height) {
      return res.status(404).json({ message: 'Height data not found for this user.' });
    }
    const heightInMeters = parseFloat(userChoice.height) / 100; // Convert height from cm to meters

    // Sort the daydate array by todaydate in ascending order
    userProgress.daydate.sort((a, b) => new Date(a.todaydate) - new Date(b.todaydate));

    // Get the first and last entry based on todaydate
    const firstEntry = userProgress.daydate[0];
    const lastEntry = userProgress.daydate[userProgress.daydate.length - 1];

    // Calculate the current weights and the difference
    const firstWeight = parseFloat(firstEntry.currentweight);
    const lastWeight = parseFloat(lastEntry.currentweight);
    const weightDifference = (lastWeight - firstWeight).toFixed(2);

    // Calculate how many kg left to reach the goal weight
    const goalWeight = parseFloat(lastEntry.goalWeight);
    const kgLeftToGoal = (lastWeight - goalWeight).toFixed(2);

    // Calculate BMI
    const bmi = (lastWeight / (heightInMeters * heightInMeters)).toFixed(2);

    return res.json({
      firstEntryWeight: firstWeight.toFixed(2),
      lastEntryWeight: lastWeight.toFixed(2),
      weightDifference: weightDifference,
      kgLeftToGoal: kgLeftToGoal,
      bmi: bmi
    });
  } catch (error) {
    console.error('Error processing buttonINFOCURRENT request:', error);
    return res.status(500).json({ message: 'Internal server error.' });
  }
};