const express = require('express');
const router = express.Router();
const path = require('path');
const bodyParser = require('body-parser');
const session = require('express-session');
const cookieParser = require('cookie-parser');
const fs = require('fs');

 
const multer = require('multer');

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const product = require('../models/product');

// exports.getAdd=async(req,res)=>{

//     try {
//         if (!req.file) {
//             return res.status(400).send('No image uploaded.');
//         }

//         // Create a new Image document
//         // const newImage = new imageModel({
//         //     data: req.file.buffer,
//         //     contentType: req.file.mimetype
//         // });

//         // // Save the image to MongoDB
//         // await newImage.save();
        
//         const { nameproduct, priceproduct } = req.body;


//         const base64ImageData = req.file.buffer.toString('base64');

//         // Check if a product with the same name and price already exists
//         let existingProduct = await product.findOne({ nameproduct, priceproduct });

//         if (!existingProduct) {
//             // If the product doesn't exist, create a new one
//             // Find the last inserted product
//             let lastProduct = await product.findOne({}, { idproduct: 1 }).sort({ idproduct: -1 }).exec();
//             // Generate a new unique ID for the next product
//             const newId = lastProduct ? lastProduct.idproduct + 1 : 1;
            
//             // Create a new product object
//             let newProduct = new product({
//                 idproduct: newId,
//                 nameproduct,
//                 priceproduct,
//                 countproduct: 1,// Initialize countproduct to 1 for the new product
//                 data: base64ImageData,
//                 contentType: req.file.mimetype
//             });
//            console.log('Image uploaded successfully!');

//             // Save the new product to the database
//             await newProduct.save();
//             res.redirect('/Home');
//         } else {
//             // If the product exists, increment its count
//             existingProduct.countproduct += 1;
//             await existingProduct.save();
//             console.log('Product count increased');
//             res.redirect('/Home');
//         }
//     } catch (error) {
//         console.error('Error adding product:', error);
//         res.status(500).send('Internal Server Error');
//     }
// };




 
// exports.getAdd=async(req,res)=>{
// // app.post('/upload', upload.single('image'), async (req, res) => {
//     try {
//       if (!req.file) {
//         return res.status(400).send('No file uploaded');
//       }
//       const { nameproduct, priceproduct } = req.body;
//       let existingProduct = await product.findOne({ nameproduct, priceproduct });
      
//       if (!existingProduct) {
//         // If the product doesn't exist, create a new one
//         // Find the last inserted product
//         let lastProduct = await product.findOne({}, { idproduct: 1 }).sort({ idproduct: -1 }).exec();
//         // Generate a new unique ID for the next product
//         const newId = lastProduct ? lastProduct.idproduct + 1 : 1;
        
//         // Create a new product object
//         let newProduct = new product({
//             idproduct: newId,
//             nameproduct,
//             priceproduct,
//             countproduct: 1,// Initialize countproduct to 1 for the new product
//             data: base64ImageData,
//             contentType: req.file.mimetype
//         });
//        console.log('Image uploaded successfully!');

//         // Save the new product to the database
//         await newProduct.save();
//     }else {
//         // If the product exists, increment its count
//         existingProduct.countproduct += 1;
//         await existingProduct.save();
//         console.log('Product count increased');
//         res.redirect('/Home');
//     }
//       // Create a new instance of your product model
//       const newImage = new product();
//       newImage.data = fs.readFileSync(req.file.path); // Read the uploaded file
//       newImage.contentType = req.file.mimetype; // Set the MIME type of the file
//       await newImage.save(); // Save the file details to the database
//       fs.unlinkSync(req.file.path); // Delete temporary file after saving to DB
//       res.status(200).send('Image uploaded successfully');
//     } catch (error) {
//       console.error(error);
//       res.status(500).send('Error uploading image');
//     }
// //   });
// }

//////////////////////////////////////

// exports.getAdd = async (req, res) => {
//     try {
//         // Check if an image file was uploaded
//         if (!req.file) {
//             return res.status(400).send('No file uploaded');
//         }

//         // Extract product details from the request body
//         const { nameproduct, priceproduct } = req.body;

//         // Check if a product with the same name and price already exists
//         let existingProduct = await product.findOne({ nameproduct, priceproduct });

//         if (!existingProduct) {
//             // If the product doesn't exist, create a new one

//             // Find the last inserted product
//             let lastProduct = await product.findOne({}, { idproduct: 1 }).sort({ idproduct: -1 }).exec();

//             // Generate a new unique ID for the next product
//             const newId = lastProduct ? lastProduct.idproduct + 1 : 1;

//             // Create a new product object
//             let newProduct = new product({
//                 idproduct: newId,
//                 nameproduct,
//                 priceproduct,
//                 countproduct: 1, // Initialize countproduct to 1 for the new product
//                 data: fs.readFileSync(req.file.path), // Read the uploaded file
//                 contentType: req.file.mimetype // Set the MIME type of the file
//             });

//             // Save the new product to the database
//             await newProduct.save();
//             console.log('Product added successfully!');
//         } else {
//             // If the product exists, increment its count
//             existingProduct.countproduct += 1;
//             await existingProduct.save();
//             console.log('Product count increased');
//         }

//         // Redirect to the home page or send a success response
//         res.redirect('/Home');
//     } catch (error) {
//         console.error(error);
//         res.status(500).send('Error uploading image');
//     }
// };
/////////////////////////////////////////////



exports.getAdd = async (req, res) => {
    try {
        // Check if an image file was uploaded
        if (!req.file) {
            return res.status(400).send('No file uploaded');
        }

        // Extract product details from the request body
        const { nameproduct, priceproduct,descriptionproduct } = req.body;

        // Check if a product with the same name and price already exists
        let existingProduct = await product.findOne({ nameproduct, priceproduct ,descriptionproduct});

        if (!existingProduct) {
            // If the product doesn't exist, create a new one

            // Find the last inserted product
            let lastProduct = await product.findOne({}, { idproduct: 1 }).sort({ idproduct: -1 }).exec();

            // Generate a new unique ID for the next product
            const newId = lastProduct ? lastProduct.idproduct + 1 : 1;

            // Create a new product object
            let newProduct = new product({
                idproduct: newId,
                nameproduct,
                priceproduct,
                countproduct: 1, // Initialize countproduct to 1 for the new product
                data: fs.readFileSync(req.file.path), // Read the uploaded file
                contentType: req.file.mimetype, // Set the MIME type of the file
                descriptionproduct
            });

            // Save the new product to the database
            await newProduct.save();
            console.log('Product added successfully!');

            // Return the added product details including the image
            res.status(200).json({
                idproduct: newProduct.idproduct,
                nameproduct: newProduct.nameproduct,
                priceproduct: newProduct.priceproduct,
                countproduct: newProduct.countproduct,
                imageData: {
                    data: newProduct.data.toString('base64'), // Convert buffer to base64 string
                    contentType: newProduct.contentType
                },
                descriptionproduct: newProduct.descriptionproduct
            });
        } else {
            // If the product exists, increment its count
            existingProduct.countproduct += 1;
            await existingProduct.save();
            console.log('Product count increased');

            // Return the existing product details
            res.status(200).json({
                idproduct: existingProduct.idproduct,
                nameproduct: existingProduct.nameproduct,
                priceproduct: existingProduct.priceproduct,
                countproduct: existingProduct.countproduct,
                imageData: {
                    data: existingProduct.data.toString('base64'), // Convert buffer to base64 string
                    contentType: existingProduct.contentType
                },
                descriptionproduct: existingProduct.descriptionproduct
            });
        }
    } catch (error) {
        console.error(error);
        res.status(500).send('Error uploading image');
    }
};





exports.getAddweb = async (req, res) => {
    try {
        // Check if an image file was uploaded
        if (!req.file) {
            // return res.status(400).send('No file uploaded');
            console.log('No file uploaded');
        }

        // Extract product details from the request body
        const { nameproduct, priceproduct, descriptionproduct } = req.body;
        console.log("the descr+++++"+ descriptionproduct);

        // Check if a product with the same name and price already exists
        let existingProduct = await product.findOne({ nameproduct, priceproduct ,descriptionproduct});

        if (!existingProduct) {
            // If the product doesn't exist, create a new one

            // Find the last inserted product
            let lastProduct = await product.findOne({}, { idproduct: 1 }).sort({ idproduct: -1 }).exec();

            // Generate a new unique ID for the next product
            const newId = lastProduct ? lastProduct.idproduct + 1 : 1;

            // Create a new product object
            let newProduct = new product({
                idproduct: newId,
                nameproduct,
                priceproduct,
                countproduct: 1, // Initialize countproduct to 1 for the new product
                data: fs.readFileSync(req.file.path), // Read the uploaded file
                contentType: req.file.mimetype, // Set the MIME type of the file
                descriptionproduct
            });

            // Save the new product to the database
            await newProduct.save();
            console.log('Product added successfully!');
            res.redirect('/Home');
 
        } else {
            // If the product exists, increment its count
            existingProduct.countproduct += 1;
            await existingProduct.save();
            console.log('Product count increased');

        }
    } catch (error) {
        console.error(error);
        // res.status(500).send('Error uploading image');
    }
};