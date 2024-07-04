const mongoose = require('mongoose');
const Schema=mongoose.Schema;
const product=new Schema({  
    idproduct:{type:Number ,unique:true},
    nameproduct:String,
    priceproduct:Number,
    countproduct:Number,
    data: Buffer,
    contentType: String,
    descriptionproduct:String
},{versionKey:false});
 
module.exports=mongoose.model("product",product);