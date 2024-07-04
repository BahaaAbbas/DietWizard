const mongoose = require('mongoose');
const Category_exercise = new mongoose.Schema({
    type: {
      type: String,
      required: true
  },
  numbers: {
      type: [Number],
      default: [],
      required: true
  }
  },{versionKey:false}
  );
  module.exports=mongoose.model("Category_exercises",Category_exercise);