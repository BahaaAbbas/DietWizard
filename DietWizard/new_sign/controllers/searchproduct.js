const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


const product = require('../models/product');

exports.getSearch=async(req,res)=>{

   
   
    const{nameofproduct}=req.body;
    console.log("the prodcut name : "+nameofproduct);

    // const products = await product.find({ nameproduct: nameofproduct });
    let products;
        if (nameofproduct.toLowerCase() === '') {
            // If the user searches for 'all', return all products
            products = await product.find();
        } else {
            // Otherwise, search for products with the specified name
            products = await product.find({ nameproduct: { $regex: nameofproduct, $options: 'i' } });
        }
     

    if (products.length > 0) {
 
        // Render the view and pass the product data to it
        res.render('searchproduct', { products: products });
 
    } else {
        console.log('not found');
        res.redirect('/Home');
    }
};


exports.getSearchs=async(req,res)=>{
    try {
        // Query the database for product data
        const products = await product.find();
        // Render the view and pass the product data to it
        res.render('searchproduct', { products: products });
    } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).send('Internal Server Error');
    }
}
