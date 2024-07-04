const mongoose = require('mongoose');
const Schema=mongoose.Schema;
const Notification=new Schema({  
    idnotification:{type:Number ,unique:true},
    nameuser:String,
    titleNotification:String,
    descriptionNotification:String
 
 
 
   
},{versionKey:false});
 
module.exports=mongoose.model("Notification",Notification);