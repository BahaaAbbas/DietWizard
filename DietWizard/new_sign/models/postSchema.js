const mongoose = require('mongoose');
const Schema=mongoose.Schema;
const postSchema = new mongoose.Schema({
    idPost:{type:Number ,unique:true},
    title: String,
    content: String,
    author: String,
    image: String,
    data: Buffer,
    contentType: String,
    likes: {
      type: [String],
      default: [],
      required: true
  },
comments: [{ username: String, text: String }], // Modify comments field
reportcount:Number,

  },{versionKey:false});
  

  module.exports=mongoose.model("Post",postSchema);