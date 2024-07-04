const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const historicaldiary = new Schema({
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

        beforeTDEE:String,
        afterTDEE:String,
        target: String,
        activity: String,
        sex: String,
        age: String,
        height: String,
        startweight: String,
        currentweight: String,
        goalWeight: String,
        goalweeklyPer: String,
        goalcarbsPer:String,
        goalprotienPer:String,
        goalfatPer: String,
        goalworkWeek:String,
        goalminWork:String,
        goaltotFat: String,
        goalsatFat: String,
        goalprotein: String,
        goalsodium: String,
        goalpotassium: String,
        goalcholesterol: String,
        goalcarbs: String,
        goalfiber: String,
        goalsugar: String,
    
        
    }]

}, { versionKey: false });

module.exports = mongoose.model("historicaldiary", historicaldiary);
