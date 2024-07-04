const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


const userModel = require('../models/user');
 
const userChoices =require('../models/userChoices');

exports.getShowUser=async(req,res)=>{

    try {
        // Query the database for product data
        
        const users = await userModel.find();
        // Render the view and pass the product data to it
        res.render('showusers', { users: users });
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).send('Internal Server Error');
    }
};



exports.DeleteUser=async(req,res)=>{


    try {
   
        const { iduser } = req.params;
         
        // Ensure idPost is converted to a number
        const userId = parseInt(iduser);
    
        // Check if postId is a valid number
        if (isNaN(userId)) {
            return res.status(400).send('Invalid userId');
        }
    
         
    
        //   const deleteuser = await userModel.findOneAndDelete({ email: informationcoach.email });
        //   const deleteuserchoise = await userChoices.findOneAndDelete({ email: informationcoach.email });
     
        // Find the post by postId and delete it
        // const deletedCoach = await coach.findOneAndDelete({ iduser: userId });
        const userinformation = await userModel.findOne({ iduser: userId });
        const deleteuserchoise = await userChoices.findOneAndDelete({ email: userinformation.email });
        const userdelete = await userModel.findOneAndDelete({ iduser: userId });






        // Check if the post exists
        if (!userdelete) {
            return res.status(404).send('user not found');
        }
    
        // Return a success message
        res.status(200).send('coach user successfully');
    } catch (error) {
        console.error(error);
        res.status(500).send('Failed to user coach');
    }

 
};
















exports.getShowUserAndCoach = async (req, res) => {
    // console.log("the login get is called");
    res.render('CategoryUserAndCoach', { errors: {} });
    };
