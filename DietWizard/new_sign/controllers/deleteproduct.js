const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


const product = require('../models/product');

exports.getDelete=async(req,res)=>{

    try {
        const { deleteproduct, pricedelete } = req.body;
        console.log(deleteproduct, pricedelete);

        // Find the product to delete
        let productToDelete = await product.findOne({ nameproduct: deleteproduct, priceproduct: pricedelete });

        if (productToDelete) {
            // If count is greater than 1, decrement count and save
            if (productToDelete.countproduct > 1) {
                productToDelete.countproduct -= 1;
                await productToDelete.save();
                console.log('Count decremented for:', productToDelete);
            } else {
                // If count is 1, delete the product
                await product.deleteOne({ _id: productToDelete._id });
                console.log('Deleted:', productToDelete);
            }
        } else {
            console.log('Product not found');
        }

        res.redirect('/Home');
    } catch (error) {
        console.error('Error deleting product:', error);
        res.status(500).send('Internal Server Error');
    }
};
