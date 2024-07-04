const mongoose = require('mongoose');
const Schema=mongoose.Schema;

const RecipeSchema = new mongoose.Schema({
    name: String,
    description: String,
    imageUrl: String,
    price: Number
  });



  module.exports=mongoose.model("Recipe",RecipeSchema);
