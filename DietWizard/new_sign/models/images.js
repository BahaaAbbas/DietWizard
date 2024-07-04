const mongoose = require('mongoose');
const Schema=mongoose.Schema;
const multer = require('multer');
const image=new Schema({  
    data: Buffer,
    contentType: String
});
 
module.exports=mongoose.model("image",image);