const express = require('express');
const router = express.Router();
const path = require('path');

 


const Reminder  = require('../models/reminderSchema');

const notifications = require('../models/Notification');
const userModel = require('../models/user');

exports.PostReminder=async(req,res)=>{
    try {
        const reminder = new Reminder(req.body);
        const email = req.params.email;
        console.log("the email is : "+email);
        // await reminder.save();
        const reminders = new Reminder({
            email: email,
            reminderType: req.body.reminderType,
            reminderTime: req.body.reminderTime,
            isActivated: req.body.isActivated,
          });

        await reminders.save();
        res.status(201).send(reminder);
      } catch (error) {
        res.status(400).send(error);
      }
 
}



exports.GetReminder=async(req,res)=>{
    try {
        const email = req.params.email;
 
        const reminders = await Reminder.find({ email: email });
         
     
        
        res.send(reminders);
      } catch (error) {
        res.status(500).send(error);
      }
 
}


 

exports.PutReminder = async (req, res) => {
  // Extract data from the request
  const { id } = req.params;
  const { isActivated } = req.body;
  const email = req.params.email;
  try {
      // Update the reminder in the database
      // const reminder = await Reminder.findByIdAndUpdate(id, { isActivated }, { new: true });
      const reminder = await Reminder.findByIdAndUpdate(
        { _id: id, email: email },
        { isActivated },
        { new: true }
      );

      

      // If the reminder is not found, send a 404 status code
      if (!reminder) {
          return res.status(404).send("Reminder not found.");
      }

      // If the reminder is activated
      if (isActivated) {
          // Set up an interval to check for the reminder time
          const interval = setInterval(async () => {
              const currentTime = new Date();
              const currentHour = currentTime.getHours();
              const currentMinute = currentTime.getMinutes();

              // Check if the current time matches the reminder time
              if (currentHour === reminder.reminderTime.hour && currentMinute === reminder.reminderTime.minute) {
                  console.log('Sending notification...');
                  // Deactivate the reminder and save the changes
                  // reminder.isActivated = false; // baack here bahaa
                  await reminder.save();
                  console.log("Reminder deactivated and saved.");


                  let lastnotification = await notifications.findOne({}, { idnotification: 1 }).sort({ idnotification: -1 }).exec();
  
                  // Generate a new unique ID for the next product
                  const newId = lastnotification ? lastnotification.idnotification + 1 : 1;

                  const user = await userModel.findOne({ email:email });
        
                  // Create a new post object
                  let newNotification = new notifications({
                      idnotification: newId,
                      nameuser:user.username,
                      titleNotification:"Reminder",
                      descriptionNotification:"Reminder sent.",
                  });
        
                  // Save the new product to the database
                  await newNotification.save();
                  console.log('Notification added successfully!');

                  // Send the updated reminder
                  

                  let response = {
                    reminder:reminder,
                    status: "done"
                };
                console.log(response);
                res.json(response);

                  // res.send(reminder);

                  // Stop the interval
                  clearInterval(interval);
              }
          }, 1000); // Check every 1 second

          // Clear the interval after a certain time to prevent indefinite execution
          setTimeout(() => clearInterval(interval), 600000); // Stop after 10 minutes
      } else {
          // If the reminder is not activated, send the reminder without any changes
          // res.send(reminder);
          let response = {
            reminder:reminder,
            status: "notdone"
        };
        res.json(response);
      }
  } catch (error) {
      // Handle any errors and send an appropriate response
      console.error("Error:", error);
      res.status(500).send("Internal Server Error");
  }
};














exports.DeleteReminder=async(req,res)=>{
    const reminderId = req.params.id;
    const email = req.params.email;

    try {
      // Perform deletion operation using the reminderId
      // For example, if you're using MongoDB:
      // await Reminder.deleteOne({ _id: reminderId });
      await Reminder.deleteOne({ _id: reminderId, email: email });

  
      res.status(200).json({ message: 'Reminder deleted successfully' });
    } catch (error) {
      console.error('Error deleting reminder:', error);
      res.status(500).json({ message: 'Failed to delete reminder' });
    }
}


