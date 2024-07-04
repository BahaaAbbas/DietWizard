const mongoose = require('mongoose');
const cartItemSchema = new mongoose.Schema({
    idUser: Number,
    nameUser: String,
    items: [{ name: String,imageUrl: String,price: Number,quantity: Number }], // Modify Items field

  },{versionKey:false});;


module.exports=mongoose.model("CartItem",cartItemSchema);