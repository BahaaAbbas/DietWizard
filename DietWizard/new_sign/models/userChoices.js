const mongoose = require('mongoose');
const Schema = mongoose.Schema;




const userChoices = new Schema({
    iduser:{type:Number ,unique:true}, 
    email:String,
    beforeTDEE:String,
    afterTDEE:String,
    target: String,
    activity: String,
    sex: String,
    age: String,
    height: String,
    weight: String,
    goalWeight: String,
    date: String,
    weeklyPer: String,
    carbsPer:String,
    protienPer:String,
    fatPer: String,
    workWeek:String,
    minWork:String,

    totFat: String,
    satFat: String,
    protein: String,
    sodium: String,
    potassium: String,
    cholesterol: String,
    carbs: String,
    fiber: String,
    sugar: String,


}, { versionKey: false });


module.exports=mongoose.model("userChoices",userChoices);

// mealName: String,
// totCalories: Number,
// size: String,
// totFat: String,
// satFat: String,
// protein: String,
// sodium: String,
// potassium: String,
// cholesterol: String,
// carbs: String,
// fiber: String,
// sugar: String,