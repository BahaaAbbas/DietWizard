const mongoose = require('mongoose');
const Schema = mongoose.Schema;



const coachesListUser = new Schema({

    coachid:{type:Number ,unique:true}, 
    coachemail:String,
    coach: [{
        
        traineeEmail: String,
        traineeName: String,
        startdate: String,
        enddate: String,
    }],

    currentNumTrainee:String,
    

    

}, { versionKey: false });


module.exports=mongoose.model("coachesListUser",coachesListUser);