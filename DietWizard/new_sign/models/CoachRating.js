const mongoose = require('mongoose');
const Schema = mongoose.Schema;


const coachrating = new Schema({
  coachid: { type: Number, unique: true },
  coachemail: String,

  trainees: [{
    traineeEmail: String,
    traineeRate: String,
  }],
  
  currentRate: String,
  NumOfRates:String,

}, { versionKey: false });

module.exports = mongoose.model("coachrating", coachrating);
