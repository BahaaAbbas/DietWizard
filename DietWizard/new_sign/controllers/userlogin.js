const express = require('express');
 
const router = express.Router();
const path = require('path');
 
const bcrypt = require('bcrypt');

const jwt = require('jsonwebtoken');

const userModel = require('../models/user');


 

 



exports.postLoginPageWeb=async(req,res)=>{
    // here for web
    try{
        console.log("the login post is called");
        const{email,password}=req.body;
        console.log(email,password);
        
        const user = await loginUser(email, password);
        
        // const user=await userModel.findOne({email:email,password:password});
        if(user){
          if(user.type=='admin'){
            req.session.user = { email, email: user.email };
            console.log("the name is "+user.username);
            // res.redirect('/Home');
            res.redirect('/ControlPanel');
          }else{
            console.log('not found');
            
            res.redirect('/Login');
          }
            
        }else{
            console.log('not found');
            
            res.redirect('/Login');
        }
    }catch(error){
        console.log(error);
    }
  }
////////////////////////////////////////////

async function loginUser(email, password) {
  try {
      // Retrieve user record from the database based on username
      const user = await userModel.findOne({ email });

      if (user) {
          // Compare hashed password stored in the database with the password provided during login
          const passwordMatch = await bcrypt.compare(password, user.password);

          if (passwordMatch) {
              // Passwords match, authentication successful
              console.log('User authenticated');
              console.log(`password= ${password}`);
              console.log(`password= ${user.password}`);
              // Return the user object if authentication successful
              
              return user;
          } else {
              // Passwords don't match, authentication failed
              console.log('Incorrect password');
              // Return null if authentication failed
              return null;
          }
      } else {
          // User not found
          console.log('User not found');
          // Return null if user not found
          return null;
      }
  } catch (error) {
      // Handle error (e.g., database error)
      console.error('Error occurred:', error);
      // Return null if error occurred
      return null;
  }
}


 








  /////////////////////////////////////
  
exports.postLoginPage=async(req,res)=>{
    /////here for mobile 
        try {
           
            const { email, password } = req.body;
            

            const user = await loginUser(email, password);

          // const user = await userModel.findOne({ email, password });
          // const match = await bcrypt.compare(password, user.password);
          console.log(email, password);
       
          if (user) {
            // if(match){
            // res.sendStatus(200); // Login successful
            res.status(200).json({
                success: true,
                message: 'Login successful',
                user_name: user.username, // Include username in the response
                // other user details
              });
            // }
            
            console.log("Login Successful");
            console.log("the email is : "+email+" the password is : "+password);
           
          } else {
            res.sendStatus(401); // Unauthorized
          }
        } catch (error) {
          console.error(error);
          res.sendStatus(500); // Internal Server Error
        }

    };


 
exports.getLoginPage = async (req, res) => {
    console.log("the login get is called");
    res.render('Login', { errors: {} });
    };


    


   
      
  
    exports.getchatname=async(req,res)=>{

          try {
              const { email } = req.body;
              
  
              const user = await userModel.findOne({ email: email });

  

            console.log(email);
         
            if (user) {

              res.status(200).json({
                  success: true,
                  username: user.username, // Include username in the response
                  // other user details
                });
            
              
              console.log("Ussername return Successful");
              console.log("the email is : "+email);
             
            } else {
              res.sendStatus(401); // Unauthorized
            }
          } catch (error) {
            console.error(error);
            res.sendStatus(500); // Internal Server Error
          }
  
      };


