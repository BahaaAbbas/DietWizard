const express = require('express');
const validator = require("validator");
const router = express.Router();
const path = require('path');
const bcrypt = require('bcrypt');

const jwt = require('jsonwebtoken');


const userModel = require('../models/user');

 
const userChoices =  require('../models/userChoices');
const notifications = require('../models/Notification');
const Reminder = require('../models/reminderSchema'); // Adjust the path as needed



exports.postSiginupPage=async(req,res)=>{
    try{
        const{username,password,email,firstname,lastname}=req.body;
        console.log(username,password,email,firstname,lastname);
        
        // const user=await userModel.findOne({email:email});

        const user = await userModel.findOne({ $or: [{ email: email }, { username: username }] });
        const admin = await userModel.findOne({ type: 'admin' });


        if (username.toLowerCase().includes('admin')) {
            return res.status(400).json('username cannot contain the word "admin"' );
          }
       
       
          if (
            !validator.isStrongPassword(password, {
              minLength: 8,
              maxLength: 20,
              minLowercase: 1,
              minUppercase: 1,
              minNumbers: 1,
              minSymbols: 1,
            })
          ) {
            // errors.password =
            //   "Password must be between 8 and 20 characters and contain at least one lowercase letter, one uppercase letter, one number, and one symbol.";
              return res.status(400).json(' Password must be between 8 and 20 characters and contain at least one lowercase letter, one uppercase letter, one number, and one symbol.' );

          }
          if (!validator.isEmail(email)) {
            // errors.email = "Invalid email format.";
            return res.status(400).json(  'Invalid email format.' );
          }

        
        if(!user){

          const saltRounds = 10;
          const hashedPassword = await bcrypt.hash(password, saltRounds);
          // console.log(hashedPassword);

            

            let lastid = await userModel.findOne({}, { iduser: 1 }).sort({ iduser: -1 }).exec();
                // Generate a new unique ID for the next product
                const new_Id = lastid ? lastid.iduser + 1 : 1;
             
            let usermodel=new userModel({
                iduser:new_Id,
                username,
                password:hashedPassword,
                email,
                firstname,
                lastname,
                type:'user',
            });
           await usermodel.save();



           let lastnotification = await notifications.findOne({}, { idnotification: 1 }).sort({ idnotification: -1 }).exec();
  
           // Generate a new unique ID for the next product
           const newId = lastnotification ? lastnotification.idnotification + 1 : 1;
 
           // Create a new post object
           let newNotification = new notifications({
               idnotification: newId,
               nameuser:admin.username,
               titleNotification:"New user added",
               descriptionNotification:"A new user has been added. Please check it out.",
           });
 
           // Save the new product to the database
           await newNotification.save();
           console.log('Notification added successfully!');

          //   // Create reminders for the new user
            const reminders = [
              { email, reminderType: "Water", reminderTime: { hour: 10, minute: 0 }, isActivated: true },
              { email, reminderType: "Logging", reminderTime: { hour: 11, minute: 0 }, isActivated: true },
              { email, reminderType: "Logging", reminderTime: { hour: 20, minute: 0 }, isActivated: true },
          ];

          await Reminder.insertMany(reminders);
          console.log('Reminders added successfully!');







           res.sendStatus(200);
            res.redirect('/Home');
        }else{
            console.log('user already exist');
            return res.status(400).json(  'user already exist' );
            res.redirect('/signup');
        }
      }catch(error){
        console.log("The Error is :"+error);
      }
    };


    //for web
    exports.postSiginupWebPage=async(req,res)=>{
      try{
          const{username,password,email,firstname,lastname}=req.body;
          console.log(username,password,email,firstname,lastname);
          
          // const user=await userModel.findOne({email:email});
  
          const user = await userModel.findOne({ $or: [{ email: email }, { username: username }] });
  
  
          if (username.toLowerCase().includes('admin')) {
              // return res.status(400).json('username cannot contain the word "admin"' );
            }
         
         
            if (
              !validator.isStrongPassword(password, {
                minLength: 8,
                maxLength: 20,
                minLowercase: 1,
                minUppercase: 1,
                minNumbers: 1,
                minSymbols: 1,
              })
            ) {
              // errors.password =
              //   "Password must be between 8 and 20 characters and contain at least one lowercase letter, one uppercase letter, one number, and one symbol.";
                // return res.status(400).json(' Password must be between 8 and 20 characters and contain at least one lowercase letter, one uppercase letter, one number, and one symbol.' );
  
            }
            if (!validator.isEmail(email)) {
              // errors.email = "Invalid email format.";
              // return res.status(400).json(  'Invalid email format.' );
            }
  
          
          if(!user){
  
            const saltRounds = 10;
            const hashedPassword = await bcrypt.hash(password, saltRounds);
            // console.log(hashedPassword);
  
              
  
              let lastid = await userModel.findOne({}, { iduser: 1 }).sort({ iduser: -1 }).exec();
                  // Generate a new unique ID for the next product
                  const new_Id = lastid ? lastid.iduser + 1 : 1;
               
              let usermodel=new userModel({
                  iduser:new_Id,
                  username,
                  password:hashedPassword,
                  email,
                  firstname,
                  lastname,
                  type:'admin',
              });
             await usermodel.save();
            //  res.sendStatus(200);
              res.redirect('/Home');
          }else{
              console.log('user already exist');
              // return res.status(400).json(  'user already exist' );
              res.redirect('/signup');
          }
        }catch(error){
          console.log("The Error is :"+error);
        }
      };
  


 
exports.getSiginupPage = async (req, res) => {
    console.log("the login get is called");
    res.render('signup', { errors: {} });
    };








