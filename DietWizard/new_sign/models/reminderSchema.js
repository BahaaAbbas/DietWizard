const mongoose = require('mongoose');
const Schema=mongoose.Schema;

const reminderSchema = new mongoose.Schema({
  email: String,
    reminderType: String,
    reminderTime: {
      hour: Number,
      minute: Number,
    },
    isActivated: Boolean,
  
    
  },{versionKey:false});
  
  module.exports= mongoose.model('Reminder', reminderSchema);