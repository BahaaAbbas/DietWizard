const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


const product = require('../models/product');

exports.getShowproduct=async(req,res)=>{

    try {
        // Query the database for product data
        const products = await product.find();
        // Render the view and pass the product data to it
        res.render('showproducts', { products: products });
    } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).send('Internal Server Error');
    }
};


exports.getShowproductmobile=async(req,res)=>{

 
    try {
      // Fetch all products from the database
      const products = await product.find();
  
      // Return the products as JSON response
      res.json(products);
    } catch (error) {
      // If an error occurs, log the error and send a 500 status response
      console.error(error);
      res.status(500).send('Error fetching products');
    }
  };
