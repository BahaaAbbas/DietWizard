const mongoose = require('mongoose');
const Schema=mongoose.Schema;

 user=new Schema({
    iduser:{type:Number ,unique:true},  
    username:String,
    password:String,
    email: String ,
    firstname:String,
    lastname:String,
    type:String
},{versionKey:false});


module.exports=mongoose.model("user",user);





