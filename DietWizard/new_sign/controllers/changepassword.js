const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');

const validator = require("validator");
const bcrypt = require('bcrypt');

const userModel = require('../models/user');

exports.changepass=async(req,res)=>{
    const {email,oldpassword,newpassword}=req.body;
    console.log(email,oldpassword,newpassword);
    try{
      // const user=await userModel.findOne({email:email,password:oldpassword});

      const user = await loginUser(email, oldpassword);

    if(!user){
      return res.status(404).json({ error: 'User not found' });
    }
    console.log('user is '+user.email + "the password is "+user.password);

    if (
      !validator.isStrongPassword(newpassword, {
        minLength: 8,
        maxLength: 20,
        minLowercase: 1,
        minUppercase: 1,
        minNumbers: 1,
        minSymbols: 1,
      })
    ) {
      // Assign the new password to the user object
      return res.status(400).json(' Password must be between 8 and 20 characters and contain at least one lowercase letter, one uppercase letter, one number, and one symbol.' );

      // user.password=newpassword;
  }else {
      // errors.password =
      //   "Password must be between 8 and 20 characters and contain at least one lowercase letter, one uppercase letter, one number, and one symbol.";
        // return res.status(400).json(' Password must be between 8 and 20 characters and contain at least one lowercase letter, one uppercase letter, one number, and one symbol.' );
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(newpassword, saltRounds);
        // const user = await loginUser(email, hashedPassword);
        user.password=hashedPassword;
    }
    // user.password=newpassword;
    console.log('user is '+user.email + " the password is "+user.password);
    await user.save();
    return res.status(200).json({ message: 'Password changed successfully' });
    }catch(error){
      console.error('Error changing password:', error);
       return res.status(500).json({ error: 'Internal server error' });
    }      
 
};


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

