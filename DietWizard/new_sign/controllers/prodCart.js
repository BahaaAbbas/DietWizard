const express = require('express');
const router = express.Router();
const path = require('path');
const bodyParser = require('body-parser');
 
const userModel = require('../models/user');
const ProductcartItem = require('../models/productcart');


exports.AddProductCart = async (req, res) => {    
    try {
        // Check if an image file was uploaded
       
  
        const { productId, name, price, count  ,user,imageData } = req.body;
        // console.log(imageData);// user name
        
        const usercart = await userModel.find({ username: user });
        const idforuser = usercart[0].iduser;
        const productcart = await ProductcartItem.findOne({ idUser: idforuser });
        
      if (!productcart) {
        // If user doesn't have a cart, create a new one
        const newproductcart = new ProductcartItem({ idUser: idforuser, name: user, items: [{ 
            name, 
            price, 
            count: 1,
            data: Buffer.from(imageData, 'base64') 
           }]
           });
  
        await newproductcart.save();
        return res.status(200).send('Item added to cart successfully!');
    } else {
        // If user already has a cart
        const existingItemIndex = productcart.items.findIndex(item => item.name === name);
        if (existingItemIndex !== -1) {
            // If item already exists in cart, increase its quantity
            productcart.items[existingItemIndex].count += 1;
        } else {
            // If item doesn't exist in cart, add it
            productcart.items.push({ name,   price, count: 1,data: Buffer.from(imageData, 'base64')  });
        }
        await productcart.save();
        return res.status(200).send('Item added to cart successfully!');
    }  
  
         
      } catch (error) {
        console.error(error);
        res.status(500).send('Error adding item to cart');
      }

}








exports.GetProductCart = async (req, res) => {  
    try {
       
        // console.log("the product get is called");
        const { nameuser } = req.params;
      // const username = req.params.username;
      // console.log("the username is "+nameuser);
      // const username= "Ibrahim";
      // Find the user by username
      const user = await userModel.findOne({ username: nameuser });
      if (!user) {
        return res.status(404).send('User not found');
      }
      
      // Find the cart items for the user
      const cartItems = await ProductcartItem.findOne({ idUser: user.iduser });
      if (!cartItems) {
        return res.status(404).send('Cart not found');
      }
       
      res.status(200).json(cartItems.items);
      // console.log(cartItems.items);

      
    } catch (error) {
      console.error(error);
      res.status(500).send('Error retrieving cart items');
    }





 }






 exports.DeleteProductCart = async (req, res) => {  

    try {
        const { nameuser } = req.params;
          // const username = req.params.username;
          // console.log("the username is "+nameuser);
        const { productName } = req.params;
        const user = await userModel.findOne({ username: nameuser }); // Assuming the username is fixed for now
        
        if (!user) {
          return res.status(404).send('User not found');
        }
    
        const productcart = await ProductcartItem.findOne({ idUser: user.iduser });
        
        if (!productcart) {
          return res.status(404).send('Cart not found');
        }
    
        // Find the index of the item to delete
        const itemIndex = productcart.items.findIndex(item => item.name === productName);
        
        if (itemIndex === -1) {
          return res.status(404).send('Item not found in cart');
        }
    
        // Remove the item from the cart
        productcart.items.splice(itemIndex, 1);
        await productcart.save();
        
        res.status(200).send('Item deleted from cart successfully!');
      } catch (error) {
        console.error(error);
        res.status(500).send('Error deleting item from cart');
      }




 }



 exports.DecreaseProductCart = async (req, res) => {  


    try {
        const { nameuser } = req.params;
          // const username = req.params.username;
          // console.log("the username is "+nameuser);
        const { productName } = req.params;
        const user = await userModel.findOne({ username: nameuser }); // Assuming the username is fixed for now
        
        if (!user) {
          return res.status(404).send('User not found');
        }
    
        const productcart = await ProductcartItem.findOne({ idUser: user.iduser });
        
        if (!productcart) {
          return res.status(404).send('Cart not found');
        }
    
        // Find the item in the cart
        const item = productcart.items.find(item => item.name === productName);
        
        if (!item) {
          return res.status(404).send('Item not found in cart');
        }
    
        // Decrease count by 1 if count is above 1, otherwise remove the item
        if (item.count > 1) {
          item.count -= 1;
        } else {
          // Remove the item from the cart
          const itemIndex = productcart.items.findIndex(item => item.name === productName);
          if (itemIndex !== -1) {
            productcart.items.splice(itemIndex, 1);
          }
        }
        
        await productcart.save();
        res.status(200).send('Item count decreased successfully!');
      } catch (error) {
        console.error(error);
        res.status(500).send('Error decreasing item count');
      }






 }