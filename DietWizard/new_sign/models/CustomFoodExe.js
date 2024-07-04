const mongoose = require('mongoose');
const Schema = mongoose.Schema;



const customfoodexe = new Schema({
    iduser:{type:Number ,unique:true}, 
    email:String,
    food: [{

        mealName: String,
        totCalories: String,
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
    
    exerc: [{
        ExerName: String,
        totCalories: String,
        time: String,
        disc: String,
  
    }]
    

}, { versionKey: false });


module.exports=mongoose.model("customfoodexe",customfoodexe);