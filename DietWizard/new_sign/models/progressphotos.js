const mongoose = require('mongoose');
const Schema = mongoose.Schema;



const progressphoto = new Schema({
    iduser:{type:Number ,unique:true}, 
    email:String,
    photo: [{
        date: String,
        weight: String,
        image: [{
            data: Buffer,
            contentType: String,

        }],
    }]
    

}, { versionKey: false });


module.exports=mongoose.model("progressphoto",progressphoto);