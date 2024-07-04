const express = require('express');
const router = express.Router();
const path = require('path');
const bodyParser = require('body-parser');
const historicaldiary = require('../models/historicalDiary');
const dailytrackprogress = require('../models/DailyTrackProgress');
const coachrating = require('../models/CoachRating');
const coachesListUser = require('../models/CoachesListUser');
const weeklyTemCoach = require('../models/WeeklyTemCoach'); 


const fs = require('fs');

 
const validator = require("validator");
 
 
const bcrypt = require('bcrypt');

const jwt = require('jsonwebtoken');

 
const multer = require('multer');

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const coach =require('../models/coach');
const userModel = require('../models/user');
const userChoices =  require('../models/userChoices');
const notifications = require('../models/Notification');

exports.postSiginupcoachPage=async(req,res)=>{
    try{
      if (!req.file) {
        return res.status(400).send('No file uploaded');
    }
        // const{username,password,email,firstName,lastName,age,gender,yearsexperiences,qualifications,Weight,height,Numberoftrainees}=req.body;
        const{email, yearsexperiences,qualifications,Numberoftrainees}=req.body;

        // console.log(username,password,email, yearsexperiences,qualifications,Numberoftrainees);
        
        const userinformation =await userModel.findOne({email:email});

        const user = await coach.findOne({ $or: [{ email: email }, { username:userinformation.username}] });

        const coachinformation = await userChoices.findOne({ email: email });
  

        const admin = await userModel.findOne({ type: 'admin' });


        if (userinformation.username.toLowerCase().includes('admin')) {
            return res.status(400).json('username cannot contain the word "admin"' );
          }
       
       
          if (
            !validator.isStrongPassword(userinformation.password, {
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
          const hashedPassword = await bcrypt.hash(userinformation.password, saltRounds);
          // console.log(hashedPassword);

            

            let lastid = await coach.findOne({}, { idcoach: 1 }).sort({ idcoach: -1 }).exec();
                // Generate a new unique ID for the next product
                const new_Id = lastid ? lastid.idcoach + 1 : 1;
             
            let coachmodel=new coach({
                idcoach:new_Id,
                username:userinformation.username,
                password:hashedPassword,
                email,
                firstname:userinformation.firstname,
                lastname:userinformation.lastname,
                age:coachinformation.age,
                gender:coachinformation.sex,
                yearsexperiences,
                qualifications,
                Weight:coachinformation.weight,
                height:coachinformation.height,
                Numberoftrainees,
                data: fs.readFileSync(req.file.path), // Read the uploaded file
                contentType: req.file.mimetype, // Set the MIME type of the file
            });
           await coachmodel.save();









           let lastnotification = await notifications.findOne({}, { idnotification: 1 }).sort({ idnotification: -1 }).exec();
  
           // Generate a new unique ID for the next product
           const newId = lastnotification ? lastnotification.idnotification + 1 : 1;
 
           // Create a new post object
           let newNotification = new notifications({
               idnotification: newId,
               nameuser:admin.username,
               titleNotification:"New coach added",
               descriptionNotification:"A new coach has been added. Please check it out.",
           });
 
           // Save the new product to the database
           await newNotification.save();
           console.log('Notification added successfully!');











           res.sendStatus(200).json({



            idcoach:coachmodel.idcoach,
            username:coachmodel.username,
            password:coachmodel.password,
            email:coachmodel.email,
            firstname:coachmodel.firstname,
            lastname:coachmodel.lastname,
            age:coachmodel.age,
            gender:coachmodel.gender,
            yearsexperiences:coachmodel.yearsexperiences,
            qualifications:coachmodel.qualifications,
            Weight:coachmodel.Weight,
            height:coachmodel.height,
            Numberoftrainees:coachmodel.Numberoftrainees,
            imageData: {
              data: coachmodel.data.toString('base64'), // Convert buffer to base64 string
              contentType: coachmodel.contentType
          },


          
          



           });



           // notifications


           










            
        }else{
            console.log('user already exist');
            return res.status(400).json(  'user already exist' );
             
        }
      }catch(error){
        console.log("The Error is :"+error);
      }
    };



///// if want to return all coachs with their details
    exports.GetAllcoachPageInformation=async(req,res)=>{
      try {

            const coaches = await coach.find();

            res.json(coaches);
            // console.log(coaches);
          } catch (error) {
            console.log("Error fetching coaches:", error);
            res.status(500).json({ error: 'Internal server error' });
          }
    };

    exports.GetAllcoachPage = async (req, res) => {
      try {
       
        const coaches = await coach.find();
    
      
        const coachPromises = coaches.map(async (coach) => {
          const user = await userModel.findOne({ email: coach.email, type: 'coach' });
          if (user) {
            return coach;
          }
        });
    
     
        const validCoaches = (await Promise.all(coachPromises)).filter(Boolean);
    
        res.json(validCoaches);
      } catch (error) {
        console.log('Error fetching coaches:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    };


    // return coach depend in name
    exports.GetcoachPage=async(req,res)=>{
    try {

      const coachName = req.params.name;
      console.log(coachName + `  should be coachname db`);
      const foundCoach = await coach.findOne({ username: coachName });
     
      
      if (foundCoach) {
        res.json(foundCoach);
        console.log(  ` db1`);
      } else {
        res.status(404).json({ error: 'Coach not found' });
        console.log(  ` db2`);
      }
    } catch (error) {
      console.log("Error fetching coach:", error);
      res.status(500).json({ error: 'Internal server error' });
      console.log(  ` db3`);
    }
  };




  exports.deletecoach=async(req,res)=>{

    try {
     
      const { idcoach } = req.params;
       
      // Ensure idPost is converted to a number
      const coachId = parseInt(idcoach);

      // Check if postId is a valid number
      if (isNaN(coachId)) {
          return res.status(400).send('Invalid coachId');
      }
      const informationcoach = await coach.findOne({ idcoach: coachId });
      
      const deleteuser = await userModel.findOneAndDelete({ email: informationcoach.email });
      const deleteuserchoise = await userChoices.findOneAndDelete({ email: informationcoach.email });
      
      // Find the post by postId and delete it
      const deletedCoach = await coach.findOneAndDelete({ idcoach: coachId });
      const coachratingcheck = await coachrating.findOneAndDelete({  coachid: coachId  });
     // const coachlistusers = await coachesListUser.findOneAndDelete({  coachid: coachId  });



      
      // Check if the post exists
      if (!deletedCoach) {
          return res.status(404).send('coach not found');
      }

      // Return a success message
      res.status(200).send('coach deleted successfully');
  } catch (error) {
      console.error(error);
      res.status(500).send('Failed to delete coach');
  }
     
  };







  // exports.checkStatus=async(req,res)=>{

  //   try {
     
  //     const { nameuser } = req.params;
 
    
  //     const user = await userModel.find({ username: nameuser });
  //     // Check if the post exists
  //     if (!user) {
  //         return res.status(404).send('user not found');
  //     }
  //     // Return a success message
  //     // console.log(user);
  //     res.json(user);
  // } catch (error) {
  //     console.error(error);
  //     res.status(500).send('Failed to delete coach');
  // }
     
  // };



  exports.checkStatus=async(req,res)=>{

    try {
     
      const { nameuser } = req.params;
 
     
      const user = await userModel.find({ username: nameuser });
      const activecoach = await coach.findOne({ username: nameuser });
      
      // console.log(activecoach);
      // Check if the post exists
      if (user.type = "coach" ) {
        res.json(user);
      }else if(user.type = "admin"){
        console.log(user);
        res.json(user);
      }else if(user.type = "user"){
        res.json(user);
      }
   
      else{
        return res.status(404).send('user not found');
      }
      // return res.status(404).send('user not found');
      // res.json(user);
  } catch (error) {
      console.error(error);
      res.status(500).send('Failed to delete coach');
  }
     
  };







  exports.activatecoach=async(req,res)=>{

    try {

      
     
      const { idcoach } = req.params;

       
      // Ensure idPost is converted to a number
      const coachId = parseInt(idcoach);

      // Check if postId is a valid number
      if (isNaN(coachId)) {
          return res.status(400).send('Invalid coachId');
      }

      // Find the post by postId and delete it
      const activatedCoach = await coach.findOne({ idcoach: coachId });
      const namecoach = activatedCoach.username;
      // console.log(activatedCoach[0].Activate);
      //  console.log("the name is "+namecoach);
      
       const changename = await userModel.findOne({ username: namecoach });
      // Check if the post exists
      if (activatedCoach) {

        // activatedCoach[0].Activate = true;
        activatedCoach.Activate = "true";
        changename.type = "coach";

        await activatedCoach.save();
        await changename.save();

        
        	
		 const coachratingcheck = await coachrating.findOne({ $or: [{ email: changename.email }] });
     const isUserCoach = await userModel.findOne({ email: changename.email, type: 'coach' });
     const ForCoachID = await coach.findOne({ email: changename.email});
              //-----setupcoachRating
              if(isUserCoach){
                if(!coachratingcheck){
                    
                    const newCoachRatingshema = new coachrating({
                      coachid: ForCoachID.idcoach,
                      coachemail: changename.email,
                      currentRate: '0',
                      NumOfRates: '0',
                      trainees: []
                  });
          
                  await newCoachRatingshema.save();

            }
          }

          //-----setupcoachRating

        return res.status(200).send('coach activated successfully');


      }else {
        return res.status(404).send('coach not found');
      }

      // Return a success message
      // res.status(200).send('coach deleted successfully');
  } catch (error) {
      console.error(error);
      res.status(500).send('Failed to activate coach');
  }
     
  };







  exports.SendNotification=async(req,res)=>{

    try {
     
      const { email } = req.params;
      console.log('the email from code bahaa is : ' + email);

      const user = await userModel.findOne({ email:email });

      if(user){

        let lastnotification = await notifications.findOne({}, { idnotification: 1 }).sort({ idnotification: -1 }).exec();
  
      // Generate a new unique ID for the next product
      const newId = lastnotification ? lastnotification.idnotification + 1 : 1;

      

      // Create a new post object
      let newNotification = new notifications({
          idnotification: newId,
          nameuser:user.username,
          titleNotification:"From coach ",
          descriptionNotification:"check your profile.",
      });

      // Save the new product to the database
      await newNotification.save();
      console.log('Notification added successfully!');

 


      let response = {
        
        status: "Notification added successfully"
    };
  
    res.json(response);

 

      }else{
        return res.status(404).send('user not found');
      }
      
       
  
  } catch (error) {
      console.error(error);
      res.status(500).send('Failed to activate coach');
  }
     
  };








  /// this is for web 



  exports.getShowCoachesWeb=async(req,res)=>{

    try {
        // Query the database for product data
        // const products = await product.find();
        const coaches = await coach.find();
        // Render the view and pass the product data to it
        res.render('showcoaches', { coaches: coaches });
    } catch (error) {
        console.error('Error fetching Coaches:', error);
        res.status(500).send('Internal Server Error');
    }
};





exports.activatecoachweb=async(req,res)=>{
try {
     
  const { idcoach } = req.params;
   
  // Ensure idPost is converted to a number
  const coachId = parseInt(idcoach);

  // Check if postId is a valid number
  if (isNaN(coachId)) {
      return res.status(400).send('Invalid coachId');
  }

  // Find the post by postId and delete it
  const activatedCoach = await coach.findOne({ idcoach: coachId });
  const namecoach = activatedCoach.username;
  // console.log(activatedCoach[0].Activate);
  //  console.log("the name is "+namecoach);
  
   const changename = await userModel.findOne({ username: namecoach });
  // Check if the post exists
  if (activatedCoach) {

    // activatedCoach[0].Activate = true;
    activatedCoach.Activate = "true";
    changename.type = "coach";

    await activatedCoach.save();
    await changename.save();
    return res.status(200).send('coach activated successfully');


  }else {
    return res.status(404).send('coach not found');
  }

  // Return a success message
  // res.status(200).send('coach deleted successfully');
} catch (error) {
  console.error(error);
  res.status(500).send('Failed to activate coach');
}  
};



exports.deletecoachweb=async(req,res)=>{

  try {
   
    const { idcoach } = req.params;
     
    // Ensure idPost is converted to a number
    const coachId = parseInt(idcoach);

    // Check if postId is a valid number
    if (isNaN(coachId)) {
        return res.status(400).send('Invalid coachId');
    }

      const informationcoach = await coach.findOne({ idcoach: coachId });

      const deleteuser = await userModel.findOneAndDelete({ email: informationcoach.email });
      const deleteuserchoise = await userChoices.findOneAndDelete({ email: informationcoach.email });
 
    // Find the post by postId and delete it
    const deletedCoach = await coach.findOneAndDelete({ idcoach: coachId });
     
    
    // Check if the post exists
    if (!deletedCoach) {
        return res.status(404).send('coach not found');
    }

    // Return a success message
    res.status(200).send('coach deleted successfully');
} catch (error) {
    console.error(error);
    res.status(500).send('Failed to delete coach');
}
   
};