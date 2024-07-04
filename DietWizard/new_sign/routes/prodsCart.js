const express = require("express");
const router = express.Router();
 
// const CartItems = require("../controllers/cart");
const productCartItemsNew = require("../controllers/prodCart");


router.post('/product/addcart', productCartItemsNew.AddProductCart);//add cart 
router.get('/products/shopping/:nameuser', productCartItemsNew.GetProductCart);// get cart
router.delete('/products/cart/:productName/:nameuser', productCartItemsNew.DeleteProductCart); // delete the item from cart
router.post('/products/cart/decrease/:productName/:nameuser', productCartItemsNew.DecreaseProductCart);//decrease item from  cart  


module.exports = router;