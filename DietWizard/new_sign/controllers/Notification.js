const express = require('express');
const router = express.Router();
const path = require('path');
const bodyParser = require('body-parser');
 
 
const fs = require('fs');

 
const notifications = require('../models/Notification');
const posts = require('../models/PostSchema');



exports.postNotification = async (req, res) => {
    try {
      
      
        const { titleNotification,descriptionNotification} = req.body;
        const {nameuser} = req.body;
        const {postId}=req.body;
        // console.log("the post from fornt end is     "+postId);
        let userpost = await posts.findOne({ idPost: postId });
        let UserHaveNotification = userpost.author;
        // console.log("the user information is     "+UserHaveNotification);

      
        let existingnotification = await notifications.findOne({ titleNotification, descriptionNotification });
  
        if (!existingnotification) {
            // If the existingnotification doesn't exist, create a new one
  
            // Find the last inserted existingnotification
            let lastnotification = await notifications.findOne({}, { idnotification: 1 }).sort({ idnotification: -1 }).exec();
  
            // Generate a new unique ID for the next product
            const newId = lastnotification ? lastnotification.idnotification + 1 : 1;
  
            // Create a new notification object
            let newNotification = new notifications({
                idnotification: newId,
                nameuser:UserHaveNotification,
                titleNotification,
                descriptionNotification,
            });
  
            // Save the new product to the database
            await newNotification.save();
            console.log('Notification added successfully!');
  
            // Return the added product details including the image
            res.status(200).json({
                idnotification: newNotification.idnotification,
                titleNotification: newNotification.titleNotification,
                descriptionNotification: newNotification.descriptionNotification,
 
            });
        } else {
            console.log('Notification already exists!');    
            res.status(400).send('Notification already exists!');
        }
    } catch (error) {
        console.error(error);
        res.status(500).send('Error');
    }          
};



exports.getNotification = async (req, res) => {
    try {
        const { nameuser } = req.params;

        
        const userNotifications = await notifications.find({ nameuser });

        if (userNotifications.length > 0) {
            // If notifications are found, return them
            res.status(200).json(userNotifications);
        } else {
            // If no notifications are found for the given nameuser
            res.status(404).send('No notifications found for the specified user.');
        }
    } catch (error) {
        console.error(error);
        res.status(500).send('Error');
    }
};




exports.deleteNotification = async (req, res) => {
    try {
        const { idnotification } = req.params;

 
        await notifications.deleteOne({ idnotification });

        res.status(200).send('Notification deleted successfully');
    } catch (error) {
        console.error(error);
        res.status(500).send('Error');
    }
};


