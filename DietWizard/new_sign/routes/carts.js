const express = require("express");
const router = express.Router();
 
const CartItems = require("../controllers/cart");


router.post('/cart/add', CartItems.AddCart);
router.get('/cart/:user', CartItems.GetCart);
router.delete('/cart/delete/:user/:itemName', CartItems.DeleteCart);

module.exports = router;