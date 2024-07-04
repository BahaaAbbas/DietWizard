const express = require('express');
const router = express.Router();
const path = require('path');
const bodyParser = require('body-parser');
 
 
 
const CartItem =require('../models/cartItemSchema');
const userModel = require('../models/user');

 

 


exports.AddCart = async (req, res) => {     
  try {
    const { name, description, imageUrl, price, user } = req.body;

    const usercart = await userModel.find({ username: user });
    console.log(usercart);
    const idforuser = usercart[0].iduser;

    const cartItem = await CartItem.findOne({ idUser: idforuser });

    if (!cartItem) {
        // If user doesn't have a cart, create a new one
        const newCartItem = new CartItem({ idUser: idforuser, nameUser: user, items: [{ name, imageUrl, price, quantity: 1 }] });
        await newCartItem.save();
        return res.status(200).send('Item added to cart successfully!');
    } else {
        // If user already has a cart
        const existingItemIndex = cartItem.items.findIndex(item => item.name === name);
        if (existingItemIndex !== -1) {
            // If item already exists in cart, increase its quantity
            cartItem.items[existingItemIndex].quantity += 1;
        } else {
            // If item doesn't exist in cart, add it
            cartItem.items.push({ name, imageUrl, price, quantity: 1 });
        }
        await cartItem.save();
        return res.status(200).send('Item added to cart successfully!');
    }
} catch (error) {
    console.error('Error adding item to cart:', error);
    res.status(500).send('Internal Server Error');
}

   
};



exports.GetCart = async (req, res) => {
    
    try {
        const user = req.params.user;
        // console.log(user); // user name 
    
        const usercart = await userModel.find({ username: user });
    
        if (!usercart || usercart.length === 0) {
          return res.status(404).send('User not found');
        }
    
        const idforuser = usercart[0].iduser;
        // console.log(idforuser); // user id 
    
        const cartItems = await CartItem.findOne({ idUser: idforuser });
    
        if (!cartItems) {
          return res.status(404).send('Cart not found for the user');
        }
    
        res.status(200).json(cartItems.items);
        // console.log(cartItems.items);
      } catch (error) {
        console.error('Error retrieving cart items:', error);
        res.status(500).send('Internal Server Error');
      }
     
};




 


exports.DeleteCart = async (req, res) => {
  try {
      const user = req.params.user;
      const itemName = req.params.itemName;

      // Find the user by username to get the idUser
      const userCart = await userModel.findOne({ username: user });
      if (!userCart) {
          return res.status(404).send('User not found');
      }

      const idforuser = userCart.iduser;

      // Find the cart item for the user by idUser
      const cartItem = await CartItem.findOne({ idUser: idforuser });
      if (!cartItem) {
          return res.status(404).send('Cart not found for the user');
      }

      // Find the index of the item to be deleted in the items array
      const indexToDelete = cartItem.items.findIndex(item => item.name === itemName);
      if (indexToDelete === -1) {
          return res.status(404).send('Item not found in cart');
      }

      // Decrease quantity if greater than 1, otherwise remove the item
      if (cartItem.items[indexToDelete].quantity > 1) {
          cartItem.items[indexToDelete].quantity -= 1;
      } else {
          cartItem.items.splice(indexToDelete, 1);
      }

      // Save the updated cart item
      await cartItem.save();

      res.status(200).send('Item deleted from cart successfully');
  } catch (error) {
      console.error('Error deleting item from cart:', error);
      res.status(500).send('Internal Server Error');
  }
};

 