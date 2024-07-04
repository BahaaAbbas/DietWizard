const mongoose = require('mongoose');
const Schema=mongoose.Schema;
const ProductcartItemSchema = new mongoose.Schema({
    idUser: Number,
    name: String, 
    items: [{ 
      name: String,
      data: Buffer, 
      price: Number,
      count: Number 
    }], //  
  },{versionKey:false});
  module.exports=mongoose.model("ProductcartItem",ProductcartItemSchema);
