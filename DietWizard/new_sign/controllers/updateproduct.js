const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


const product = require('../models/product');

exports.getUpdate=async(req,res)=>{
    try{
        const{nameproduct,oldprice,newprice}=req.body;
    console.log(nameproduct,oldprice,newprice);
    const products = await product.updateOne({ nameproduct: nameproduct ,priceproduct:oldprice }, { $set: { priceproduct: newprice } });
    if(products){
        console.log('updated');
    }else{
        console.log('not updated');
    }
    res.redirect('/Home');
    }catch(error){
        console.log("The Error is :"+error);
    }
    

};
