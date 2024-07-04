const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const diaryinfo = new Schema({
    iduser: { type: Number, unique: true },
    email: String,

    daydate: [{
        todaydate: String,

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

}, { versionKey: false });

module.exports = mongoose.model("diaryinfo", diaryinfo);
