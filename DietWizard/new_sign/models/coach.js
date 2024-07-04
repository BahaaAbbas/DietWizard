const mongoose = require('mongoose');
const Schema=mongoose.Schema;

 coach=new Schema({
    idcoach:{type:Number ,unique:true},  
    username:String,
    password:String,
    email: String ,
    firstname:String,
    lastname:String,
	age:Number,
    gender:String,
    yearsexperiences:Number,
    qualifications:String,
    Weight:Number,
    height:Number,
    Numberoftrainees:Number,
    data: Buffer,
    contentType: String,
    Activate:{type:Boolean,default:false},
},{versionKey:false});


module.exports=mongoose.model("coach",coach);





