const mongoose = require('mongoose');
const exerciseSchema = new mongoose.Schema({
    id: Number,
   
    image: String,
    name: String,
    description: String,
    time: String,
    calories: String,
   
  },{versionKey:false}
  );


module.exports=mongoose.model("Exercise",exerciseSchema);