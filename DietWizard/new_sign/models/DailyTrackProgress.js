const mongoose = require('mongoose');
const Schema = mongoose.Schema;


const dailytrackprogress = new Schema({
  userid: { type: Number, unique: true },
  email: String,

      daydate: [{
        todaydate: String,  
      
 
        beforeTDEE:String,
        afterTDEE:String,
        remaining: String,
        burned: String,
        currentweight: String,
        goalWeight: String,
        goalweeklyPer: String,

      }]


}, { versionKey: false });

module.exports = mongoose.model("dailytrackprogress", dailytrackprogress);
