const mongoose = require('mongoose');
const Schema = mongoose.Schema;

 //Daily Water Intake = Body Weight (in kilograms) x 0.03.



const waterintake = new Schema({
    iduser:{type:Number ,unique:true}, 
    email:String,
    goalintake:String,
    log: [{
        date: String,
        time: String,
        amount: Number
    }]
    

}, { versionKey: false });


module.exports=mongoose.model("waterintake",waterintake);