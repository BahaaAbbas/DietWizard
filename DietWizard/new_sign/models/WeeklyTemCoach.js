const mongoose = require('mongoose');
const Schema = mongoose.Schema;


const weeklytemcoach = new Schema({
  coachid: { type: Number, unique: true },
  coachemail: String,
  trainees: [{
    traineeEmail: String,
    traineeName: String,
    weekLog: [{
      weekdate: String,  // Range week for example "05/20/2024 - 05/26/2024"
      logs: [{
        todaydate: String,  // Here is the date for each day, for example "05/20/2024"
        mealsExe: {
          breakfast: [{
            mealName: String,
            totCalories: Number,
            size: String,
            totFat: String,
            satFat: String,
            protein: String,
            sodium: String,
            potassium: String,
            cholesterol: String,
            carbs: String,
            fiber: String,
            sugar: String,
          }],
          lunch: [{
            mealName: String,
            totCalories: Number,
            size: String,
            totFat: String,
            satFat: String,
            protein: String,
            sodium: String,
            potassium: String,
            cholesterol: String,
            carbs: String,
            fiber: String,
            sugar: String,
          }],
          dinner: [{
            mealName: String,
            totCalories: Number,
            size: String,
            totFat: String,
            satFat: String,
            protein: String,
            sodium: String,
            potassium: String,
            cholesterol: String,
            carbs: String,
            fiber: String,
            sugar: String,
          }],
          snack: [{
            mealName: String,
            totCalories: Number,
            size: String,
            totFat: String,
            satFat: String,
            protein: String,
            sodium: String,
            potassium: String,
            cholesterol: String,
            carbs: String,
            fiber: String,
            sugar: String,
          }]
        },
        exerc: [{
          ExerName: String,
          totCalories: Number,
          time: String,
          disc: String,
        }],
        noteCont: String,
      }]
    }]
  }]
}, { versionKey: false });

module.exports = mongoose.model("weeklytemcoach", weeklytemcoach);
