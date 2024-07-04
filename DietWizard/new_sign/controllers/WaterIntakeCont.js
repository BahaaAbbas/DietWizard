const express = require('express');
 
const router = express.Router();
const path = require('path');
 
const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices =  require('../models/userChoices');
const waterintake =  require('../models/Waterintake');



exports.get7daysarray  = async (req, res) => {
    try {
        const { email } = req.body;
        console.log(email);

        const userFillChoices = await userChoices.findOne({ email: email });

        if (userFillChoices) {
            const fillInfo = await waterintake.findOne({ email: email });

            if (!fillInfo) {
                return res.status(400).json('User does not exist in the collection yet.');
            } else {
                try {
                    const today = new Date();
                    const dayIndex = today.getDay(); // Get the day index (0 for Sunday, 1 for Monday, ..., 6 for Saturday)
                    const weekStart = new Date(today); // Initialize the start of the week with today's date
                    weekStart.setDate(today.getDate() - dayIndex); // Adjust to the start of the week (Sunday)
                    const weekEnd = new Date(weekStart); // Initialize the end of the week with the start of the week
                    weekEnd.setDate(weekStart.getDate() + 6); // Adjust to the end of the week (Saturday)
                    console.log('weekStart:', weekStart);
                    console.log('weekEnd:', weekEnd);

                    const logsWithinCurrentWeek = fillInfo.log.filter(entry => {
                        const entryDate = new Date(entry.date);
                        // Compare date parts of entryDate with weekStart and weekEnd
                        return entryDate >= new Date(weekStart.getFullYear(), weekStart.getMonth(), weekStart.getDate()) && 
                            entryDate <= new Date(weekEnd.getFullYear(), weekEnd.getMonth(), weekEnd.getDate());
                    });

                    console.log('logsWithinCurrentWeek:', logsWithinCurrentWeek);

                    const dateAmountMap = new Map(); // Using a map to store total amounts for each date

                    logsWithinCurrentWeek.forEach(doc => {
                        const date = doc.date;
                        const totalAmount = dateAmountMap.has(date) ? dateAmountMap.get(date) : 0;
                        dateAmountMap.set(date, totalAmount + doc.amount);
                    });

                    console.log(dateAmountMap);

                    // Create an array to store the result
                    const dateAmountArray = [];

                    // Iterate over the days of the week and construct the result array
                    for (let i = 0; i < 7; i++) {
                        const currentDate = new Date(weekStart);
                        currentDate.setDate(weekStart.getDate() + i);
                        const dateString = formatDate(currentDate); // Format date to "4/6/2024"
                        const dayName = getDayName(currentDate.getDay());
                        const totalAmount = dateAmountMap.get(dateString) || 0;
                        dateAmountArray.push({ date: dateString, day: dayName, totalAmount: totalAmount });
                    }

                    console.log(dateAmountArray);

                    const responseObj = {
                        dateAmountArray: dateAmountArray,
                        goalintake: fillInfo.goalintake,
                    };

                    res.json(responseObj);
                } catch (error) {
                    console.error('Error:', error);
                    res.status(500).json({ error: 'Internal Server Error' });
                }
            }
        } else {
            console.log('User does not exist');
            return res.status(400).json('User does not exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
};

// Function to get the name of the day
function getDayName(dayIndex) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayIndex];
}

// Function to format date as "4/6/2024"
function formatDate(date) {
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const year = date.getFullYear();
    return `${month}/${day}/${year}`;
}


exports.deleteditloggedwater = async (req, res) => {
    try {
        const { email, goalintake, log } = req.body;
        console.log(email, goalintake, log);

        const userfillChoces = await userChoices.findOne({ $or: [{ email: email }] });

        if (userfillChoces) {
            const fillInfo = await waterintake.findOne({ $or: [{ email: email }] });

            if (!fillInfo) {
                return res.status(400).json('User not exist yet.');
            }
            else {
                const ReplaceArray = fillInfo.log; 
                flagdelete=false;
                for (let index = 0; index < ReplaceArray.length; index++) {
                    const loga = ReplaceArray[index];
                    try {

                        const logDate = loga.date;
                        const logTime = loga.time;
                        const dateTime = `${logDate} ${logTime}`; // Combine date, time, and meridian
                        ////////////////////////////////
                        ///////////////////////////////

                        const logObject = log[0]; // Accessing the object inside the array
                        const logObjectDate = logObject.date;
                        const logObjectTime = logObject.time;
                        const logObjectdateTime = `${logObjectDate} ${logObjectTime}`; // Combine date and time
             
                        console.log(`Sample: ${logObjectdateTime} --- arraymonog: ${dateTime}`);
                        ////////////////////////////////
                        ///////////////////////////////
                        if (logObjectdateTime === dateTime) {
                            console.log(`Condition met. Breaking out of loop. at index=${index}`);
                            ReplaceArray.splice(index, 1); // Remove the log object at the current index
                            flagdelete=true;
                            break; 
                        }
                    } catch (error) {
                        console.error(`Error parsing log at index ${index}: ${loga}`);
                        console.error(error);
                    }
                }
                if(flagdelete==true){

                    await waterintake.updateOne({ email: email }, { $set: { log: ReplaceArray } });
                    console.log("Below check for edit log");
                    console.log(ReplaceArray);
                    flagdelete=false;
                    return res.status(200).json('Done deleting log');

                }
                else{ // flag = false
                    return res.status(400).json('entry not exist.');
                } 
                
         
            }

        } else {
            console.log('User does not exist');
            return res.status(400).json('User does not exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}



exports.saveeditloggedwater = async (req, res) => {
    try {
        const { email, goalintake, log } = req.body;
        console.log(email, goalintake, log);

        const userfillChoces = await userChoices.findOne({ $or: [{ email: email }] });

        if (userfillChoces) {
            const fillInfo = await waterintake.findOne({ $or: [{ email: email }] });

            if (!fillInfo) {
                return res.status(400).json('User not exist yet.');
            } else {
                const logArray = fillInfo.log; 
                const times = [];

                logArray.forEach((loga, index) => {
                    try {
                        const logDate = loga.date;
                        const logTime = loga.time;
                        
                        const dateTime = `${logDate} ${logTime}`; // Combine date, time, and meridian
                        times.push(dateTime); // Push combined date and time into times array
                    } catch (error) {
                        console.error(`Error parsing log at index ${index}: ${loga}`);
                        console.error(error);
                    }
                });

                console.log(times); 

                const checkForDuplicate = (times, logc) => {
                    const logObject = logc[1]; // Accessing the object inside the array
                    const logDate = logObject.date;
                    const logTime = logObject.time;
                    const dateTime = `${logDate} ${logTime}`; // Combine date and time
                    console.log(`what should record be = ${dateTime}`);
                    return times.includes(dateTime);
                };

                const isDuplicate = checkForDuplicate(times, log);
                console.log(isDuplicate + "--> what the result");

                if (isDuplicate) { 
                    return res.status(400).json('Duplicate, the updated Time already exist!!');
                } else {
                    const ReplaceArray = fillInfo.log; 

                    for (let index = 0; index < ReplaceArray.length; index++) {
                        const loga = ReplaceArray[index];
                        try {

                            const logDate = loga.date;
                            const logTime = loga.time;
                            const dateTime = `${logDate} ${logTime}`; // Combine date, time, and meridian
                            ////////////////////////////////
                            ///////////////////////////////

                            const logObject = log[0]; // Accessing the object inside the array
                            const logObjectDate = logObject.date;
                            const logObjectTime = logObject.time;
                            const logObjectdateTime = `${logObjectDate} ${logObjectTime}`; // Combine date and time
                 
                            console.log(`Sample: ${logObjectdateTime} --- arraymonog: ${dateTime}`);
                            ////////////////////////////////
                            ///////////////////////////////
                            if (logObjectdateTime === dateTime) {
                                console.log(`Condition met. Breaking out of loop. at index=${index}`);
                                ReplaceArray[index] = log[1]; // Update the log object at the current index
                                break; 
                            }
                        } catch (error) {
                            console.error(`Error parsing log at index ${index}: ${loga}`);
                            console.error(error);
                        }
                    }
                    
                    await waterintake.updateOne({ email: email }, { $set: { log: ReplaceArray } });
                    console.log("Below check for edit log");
                    console.log(ReplaceArray);
                    return res.status(200).json('Done updating log');
                }
            }

        } else {
            console.log('User does not exist');
            return res.status(400).json('User does not exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}



exports.showloggedwater = async (req, res) => {
    try {
        const { email } = req.body;

        const userfillChoces = await userChoices.findOne({ email: email });

        if (userfillChoces) {
            const fillInfo = await waterintake.findOne({ email: email });

            if (!fillInfo) {
                return res.status(400).json('User does not have any logged water intake yet.');
            } else {
                const logArray = fillInfo.log;
                const formattedLogs = [];
                const today = new Date(); // Get today's date
                 totalAMOUNT=0;
                logArray.forEach(loga => {
                    const logDate = new Date(loga.date);
                    // Check if log date is the same as today's date
                    if (logDate.getDate() === today.getDate() &&
                        logDate.getMonth() === today.getMonth() &&
                        logDate.getFullYear() === today.getFullYear()) {
                        const logTime = loga.time;
                        const logAmount = loga.amount;
                        totalAMOUNT = totalAMOUNT + logAmount;
                        const formattedLog = `${loga.date}-${logTime}-${logAmount}`;
                        formattedLogs.push(formattedLog);
                    }
                });
            
                console.log(formattedLogs);
                //res.status(200).json(formattedLogs);
                console.log(totalAMOUNT);
            
                const responseObj = {
                    formattedLogs: formattedLogs,
                    goalintake: fillInfo.goalintake,
                    TodayAmount:totalAMOUNT,
                };
            
                res.json(responseObj);
            }
        } else {
            console.log('User does not exist');
            return res.status(400).json('User does not exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}


exports.logwaterdaily = async (req, res) => {
    try {
        const { email, goalintake, log } = req.body;

        const userfillChoces = await userChoices.findOne({ email: email });

        if (userfillChoces) {
            const fillInfo = await waterintake.findOne({ email: email });

            if (!fillInfo) {
                const waterintakeSchema = new waterintake({
                    iduser: userfillChoces.iduser,
                    email: email,
                    goalintake: goalintake,
                    log: log, // Store log as an array of objects
                });
                await waterintakeSchema.save();
                return res.status(200).json('done add full record');
            } else {
                const logArray = fillInfo.log; 
                const times = [];

                logArray.forEach((loga, index) => {
                    try {
                        const logDate = loga.date;
                        const logTime = loga.time;
                        
                        const dateTime = `${logDate} ${logTime}`; // Combine date, time, and meridian
                        times.push(dateTime); // Push combined date and time into times array
                    } catch (error) {
                        console.error(`Error parsing log at index ${index}: ${loga}`);
                        console.error(error);
                    }
                });

                console.log(times);

                const checkForDuplicate = (times, logc) => {
                    const logObject = logc[0]; // Accessing the object inside the array
                    const logDate = logObject.date;
                    const logTime = logObject.time;
                    const dateTime = `${logDate} ${logTime}`; // Combine date and time
                    console.log(`what should record be = ${dateTime}`);
                    return times.includes(dateTime);
                };
                
                
                const isDuplicate = checkForDuplicate(times, log);
                console.log(`result for duplicate is = ${isDuplicate}`);
                if (isDuplicate) { 
                    return res.status(400).json('Duplicate, You can update or delete this time!!');
                } else {
                    await waterintake.updateOne({ email: email }, { $push: { log: log } });
                    return res.status(200).json('done adding only log');
                }
            }

        } else {
            console.log('User does not exist');
            return res.status(400).json('User does not exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}





exports.setgoalintake=async(req,res)=>{

    try {

        const{email,goalintake}=req.body;
        console.log(email,goalintake);
       
        const userfillChoces = await userChoices.findOne({ $or: [{ email: email }] });

       // console.log(`userInfofillChoicesforidealWaterintake = ${userfillChoces}`);

        if(userfillChoces){ // found email = user


            const fillInfo = await waterintake.findOne({ $or: [{ email: email }] });

            if(!fillInfo){ // not exist email in waterintake collection..
                 // If no existing water intake record, create a new one
                 const waterintakeSchema = new waterintake({
                    iduser: userfillChoces.iduser,
                    email: email,
                    goalintake: goalintake,
                    log: [],
                });
                await waterintakeSchema.save();
                return res.status(200).json(  'done add full record' );
            } else {
                // If existing water intake record, update only the goal intake
                await waterintake.updateOne({ email: email }, { goalintake: goalintake });
                return res.status(200).json('done update only goal');
            }

          
        }
        else {

            console.log('user NOT exist');
            return res.status(400).json(  'user NOT exist' );
        }


    }catch(e){
        console.error(e);
        res.sendStatus(500); 
    }
    

   

}







exports.getidealintake=async(req,res)=>{

    try {

        const{email}=req.body;
        console.log(email);
       
        const userfillChoces = await userChoices.findOne({ $or: [{ email: email }] });

     //   console.log(`userInfofillChoicesforidealWaterintake = ${userfillChoces}`);

        if(userfillChoces){ // found email = user

            const weight = userfillChoces.weight; 
            
            let dailyWaterIntake = Math.ceil(weight * 0.03 * 1000).toString(); 

           
            return res.status(200).json({ dailyWaterIntake: dailyWaterIntake });
            
        }
        else {

            console.log('user NOT exist');
            return res.status(400).json(  'user NOT exist' );
        }


    }catch(e){
        console.error(e);
        res.sendStatus(500); 
    }
    
}








exports.PutNotificationWater = async (req, res) => {
    // Extract data from the request
    // const { id } = req.params;
    // const { isActivated } = req.body;
    const email = req.params.email;
    try {
        // Update the reminder in the database
        // const reminder = await Reminder.findByIdAndUpdate(id, { isActivated }, { new: true });
        // const reminder = await Reminder.findByIdAndUpdate(
        //   { _id: id, email: email },
        //   { isActivated },
        //   { new: true }
        // );
  
        
  
        // If the reminder is not found, send a 404 status code
        // if (!reminder) {
        //     return res.status(404).send("Reminder not found.");
        // }
  
        // If the reminder is activated
        // if (isActivated) {
            // Set up an interval to check for the reminder time


            const interval = setInterval(async () => {
                const currentTime = new Date();
                const currentHour = currentTime.getHours();
                const currentMinute = currentTime.getMinutes();
  
                // Check if the current time matches the reminder time
                if (currentHour === 1 && currentMinute === 20) {
                    console.log('Sending notification...');
                    // Deactivate the reminder and save the changes
                    // reminder.isActivated = false;
                    // await reminder.save();
                    console.log("Reminder deactivated and saved.");
  
  
                    let lastnotification = await notifications.findOne({}, { idnotification: 1 }).sort({ idnotification: -1 }).exec();
    
                    // Generate a new unique ID for the next product
                    const newId = lastnotification ? lastnotification.idnotification + 1 : 1;
  
                    const user = await userModel.findOne({ email:email });
          
                    // Create a new post object
                    let newNotification = new notifications({
                        idnotification: newId,
                        nameuser:user.username,
                        titleNotification:"water",
                        descriptionNotification:"water sent.",
                    });
          
                    // Save the new product to the database
                    await newNotification.save();
                    console.log('Notification added successfully!');
  
                    // Send the updated reminder
                    
  
                    let response = {
                    //   reminder:reminder,
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
        // } else {
            // If the reminder is not activated, send the reminder without any changes
            // res.send(reminder);
        //     let response = {
        //       reminder:reminder,
        //       status: "notdone"
        //   };
        //   res.json(response);
        // }
    } catch (error) {
        // Handle any errors and send an appropriate response
        console.error("Error:", error);
        res.status(500).send("Internal Server Error");
    }
  };