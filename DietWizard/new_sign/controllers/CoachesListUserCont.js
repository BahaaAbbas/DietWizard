
const express = require('express');

const router = express.Router();
const path = require('path');

const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices = require('../models/userChoices');
const waterintake = require('../models/Waterintake');
const progressphoto = require('../models/progressphotos');
const customfoodexe = require('../models/CustomFoodExe');
const coachmodel = require('../models/coach');
const coachesListUser = require('../models/CoachesListUser');
const fs = require('fs');

const multer = require('multer');


exports.areYou = async (req, res) => {
    try {
        const { email } = req.body; 
        console.log(`email= ${email}`);
        
        // Check if the email belongs to an admin
        const admin = await userModel.findOne({ email: email, type: "admin" });
        if (admin) {
            return res.status(200).json('admin');
        }

           // Check if the email belongs to an coach
           const coachuser = await userModel.findOne({ email: email, type: "coach" });
           if (coachuser) {
               return res.status(200).json('coach');
           }

        // Check if the email belongs to a user
        const user = await userModel.findOne({ email: email, type: "user" });
        if (user) {
            // Check if the user has a coach
            const coach = await coachesListUser.findOne({ "coach.traineeEmail": email });
            if (coach) {
                return res.status(200).json({ user: email, coach: coach.coachemail });
            } else {
                return res.status(200).json('usernocoach');
            }
        }

        // If neither an admin nor a user is found
        return res.status(400).json('Invalid email or user type');
        
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}

exports.returncoachnameandnumtrainees = async (req, res) => {
    try {
        const { coachemail } = req.body; 
        console.log(`coachemail= ${coachemail}`)
        
        // Find the coach in the user collection
        const user = await userModel.findOne({ email: coachemail, type: "coach" }, 'firstname lastname iduser');
        
        if (!user) {
            console.log(`coachemail not found!!`);
            return res.status(404).json({ message: 'Coach not found' });
        }

        // Combine first and last names
        const fullname = `${user.firstname} ${user.lastname}`;
        console.log(`coachfullname= ${fullname}`);

        // Find the number of trainees for this coach in the coach collection
        const coach = await coachmodel.findOne({ idcoach: user.iduser }, 'Numberoftrainees');
        
        if (!coach) {
            return res.status(404).json({ message: 'Coach details not found' });
        }

        // Send the response with fullname and number of trainees
        res.status(200).json({
            fullname: fullname,
            Numberoftrainees: coach.Numberoftrainees
        });
      
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}

exports.returnuserforsearch = async (req, res) => {
    try {
        // Fetch all users with type "user"
        const users = await userModel.find({ type: "user" }, 'username email');

        // Fetch all trainee emails from coachesListUser
        const coachesList = await coachesListUser.find({}, 'coach.traineeEmail');
        const traineeEmails = new Set();
        coachesList.forEach(coach => {
            coach.coach.forEach(trainee => {
                traineeEmails.add(trainee.traineeEmail);
            });
        });

        // Filter out users who are trainees
        const filteredUsers = users.filter(user => !traineeEmails.has(user.email));

        if (filteredUsers.length > 0) {
            // Send the filtered users in the response
            return res.status(200).json(filteredUsers);
        } else {
            console.log('No users found');
            return res.status(400).json('No users found');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}

exports.saveusertrainee = async (req, res) => {
    try {
        const { coachemail, trainees, currentNumTrainee } = req.body; // Extracting coachemail, trainees, and currentNumTrainee from the request body
        console.log(req.body);

        const coachmodelFind = await coachmodel.findOne({ email: coachemail });

        if (coachmodelFind) { // Checking if coach exists
            const existingCoach = await coachesListUser.findOne({ coachemail: coachemail });

            if (!existingCoach) { // If coach does not exist in coachesListUser
                const traineesData = trainees.map(trainee => ({ // Map trainees data to fit the schema
                 
                    traineeEmail: trainee.traineeEmail,
                    traineeName: trainee.traineeName,
                    startdate: trainee.startdate,
                    enddate: trainee.enddate
                }));

                // Create a new coachesListUser document
                const coachesListUserSchema = new coachesListUser({
                    coachid: coachmodelFind.idcoach,
                    coachemail: coachemail,
                    coach: traineesData, // Assign trainees data
                    currentNumTrainee: currentNumTrainee
                });

                await coachesListUserSchema.save(); // Save the new document
                return res.status(200).json('done add trainee record');
            } else { // If coach exists in coachesListUser


                  // First, clear the coach array
                  await coachesListUser.updateOne(
                    { coachemail: coachemail },
                    { $set: { coach: [] } }
                );

                // Then, push the new trainees into the coach array
                // Update existing document with new trainee data
                await coachesListUser.updateOne(
                    { coachemail: coachemail },
                    {
                        $push: {
                            coach: {
                                $each: trainees.map(trainee => ({ // Map trainees data to fit the schema

                                    traineeEmail: trainee.traineeEmail,
                                    traineeName: trainee.traineeName,
                                    startdate: trainee.startdate,
                                    enddate: trainee.enddate
                                }))
                            }
                        },
                        $set: {
                            currentNumTrainee: currentNumTrainee // Update currentNumTrainee
                        }
                    }
                );

                return res.status(200).json('done adding');
            }
        } else {
            console.log('Coach does NOT exist');
            return res.status(400).json('Coach does NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}





exports.showusertrainee = async (req, res) => {
    try {
        const { coachemail } = req.body;
        console.log(req.body);

        const fillInfo = await coachesListUser.findOne({ coachemail: coachemail });

        if (fillInfo) {
            console.log('Trainee information found:', fillInfo);
            res.status(200).json(fillInfo);
        } else {
            console.log('Trainee information not found for coach:', coachemail);
            res.status(404).json({ message: 'Trainee information not found' });
        }
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: 'Internal server error' });
    }
}
