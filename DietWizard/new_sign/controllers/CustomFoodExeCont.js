const express = require('express');

const router = express.Router();
const path = require('path');

const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices = require('../models/userChoices');
const waterintake = require('../models/Waterintake');
const progressphoto = require('../models/progressphotos');
const customfoodexe = require('../models/CustomFoodExe');
const fs = require('fs');

const multer = require('multer');

exports.savecustomFood = async (req, res) => {
    try {

        //     'email': widget.email,
        //     'mealName': mealNameController.text,
        //     'totCalories': totalCaloriesController.text,
        //     'size': servingSizeController.text,
        //     'totFat': totalFatController.text,
        //     'satFat': saturatedFatController.text,
        //     'protein': proteinController.text,
        //     'sodium': sodiumController.text,
        //     'potassium': potassiumController.text ,
        //     'cholesterol': cholesterolController.text,
        //    'carbs': carbsController.text,
        //     'fiber': fiberController.text ,
        //     'sugar': sugarController.text,

        const { email, mealName, totCalories, size, totFat, satFat, protein,
            sodium, potassium, cholesterol, carbs, fiber, sugar } = req.body;
        console.log(req.body);



        const userFillChoices = await userChoices.findOne({ email: email });

        if (userFillChoices) {
            const fillInfo = await customfoodexe.findOne({ email: email });

            if (!fillInfo) {
                // If no existing customfoodexe email record, create a new one
                const customfoodexeSchema = new customfoodexe({
                    iduser: userFillChoices.iduser,
                    email: email,
                    food: [{
                        mealName: mealName,
                        totCalories: totCalories,
                        size: size,
                        totFat: totFat,
                        satFat: satFat,
                        protein: protein,
                        sodium: sodium,
                        potassium: potassium,
                        cholesterol: cholesterol,
                        carbs: carbs,
                        fiber: fiber,
                        sugar: sugar,

                    }]
                });
                await customfoodexeSchema.save();
                return res.status(200).json('done add full record');
            } else {
                // If existing customfoodexe email record
                await customfoodexe.updateOne(
                    { email: email },
                    {
                        $push: {
                            food: [{

                                mealName: mealName,
                                totCalories: totCalories,
                                size: size,
                                totFat: totFat,
                                satFat: satFat,
                                protein: protein,
                                sodium: sodium,
                                potassium: potassium,
                                cholesterol: cholesterol,
                                carbs: carbs,
                                fiber: fiber,
                                sugar: sugar,
                            }]
                        }
                    }
                );
                return res.status(200).json('done adding');
            }
        } else {
            console.log('User does NOT exist');
            return res.status(400).json('User does NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}




exports.savecustomExe = async (req, res) => {
    try {

        // ExerName: String,
        // totCalories: String,
        // time: String,
        // disc: String,


        const { email, ExerName, totCalories, time, disc } = req.body;
        console.log(req.body);



        const userFillChoices = await userChoices.findOne({ email: email });

        if (userFillChoices) {
            const fillInfo = await customfoodexe.findOne({ email: email });

            if (!fillInfo) {
                // If no existing customfoodexe email record, create a new one
                const customfoodexeSchema = new customfoodexe({
                    iduser: userFillChoices.iduser,
                    email: email,
                    exerc: [{
                        ExerName: ExerName,
                        totCalories: totCalories,
                        time: time,
                        disc: disc

                    }]
                });
                await customfoodexeSchema.save();
                return res.status(200).json('done add full record');
            } else {
                // If existing customfoodexe email record
                await customfoodexe.updateOne(
                    { email: email },
                    {
                        $push: {
                            exerc: [{
                                ExerName: ExerName,
                                totCalories: totCalories,
                                time: time,
                                disc: disc

                            }]
                        }
                    }
                );
                return res.status(200).json('done adding');
            }
        } else {
            console.log('User does NOT exist');
            return res.status(400).json('User does NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}



exports.getcustomFood = async (req, res) => {
    try {



        const { email } = req.body;
        console.log(req.body);



        const userFillChoices = await userChoices.findOne({ email: email });

        if (userFillChoices) {
            const fillInfo = await customfoodexe.findOne({ email: email });

            if (!fillInfo) {
                // If no existing customfoodexe email record, error 400
                return res.status(400).json('User does not have any logged Food yet.');
            }  else {
                const logArray = fillInfo.food;
                const formattedLogs = [];
              
                for (const loga of logArray) {
                  const mealName = loga.mealName;
                  const totCalories = loga.totCalories;
                  const size = loga.size;
                  const totFat = loga.totFat;
                  const satFat = loga.satFat;
                  const protein = loga.protein;
                  const sodium = loga.sodium;
                  const potassium = loga.potassium;
                  const cholesterol = loga.cholesterol;
                  const carbs = loga.carbs;
                  const fiber = loga.fiber;
                  const sugar = loga.sugar;
              
                  // Push each food detail to the formattedLogs array
                  formattedLogs.push({
                    mealName: mealName,
                    totCalories: totCalories,
                    size: size,
                    totFat: totFat,
                    satFat: satFat,
                    protein: protein,
                    sodium: sodium,
                    potassium: potassium,
                    cholesterol: cholesterol,
                    carbs: carbs,
                    fiber: fiber,
                    sugar: sugar,
                  });
                }
              
                const responseObj = {
                  formattedLogs: formattedLogs,
                };
              
                res.json(responseObj);
              }
        } else {
            console.log('User does NOT exist');
            return res.status(400).json('User does NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}


exports.getcustomExe = async (req, res) => {
    try {

        // ExerName: String,
        // totCalories: String,
        // time: String,
        // disc: String,


        const { email } = req.body;
        console.log(req.body);



        const userFillChoices = await userChoices.findOne({ email: email });

        if (userFillChoices) {
            const fillInfo = await customfoodexe.findOne({ email: email });

            if (!fillInfo) {
                // If no existing customfoodexe email record, error 400
                return res.status(400).json('User does not have any logged Exercise yet.');
            } else {

                const logArray = fillInfo.exerc;
                const formattedLogs = [];

                for (const loga of logArray) {
                    const ExerName = loga.ExerName;
                    const totCalories = loga.totCalories;
                    const time = loga.time;
                    const disc = loga.disc;
                    // Push each exercise detail to the formattedLogs array
                    formattedLogs.push({
                        ExerName: ExerName,
                        totCalories: totCalories,
                        time: time,
                        disc: disc
                    });
                }

                const responseObj = {
                    formattedLogs: formattedLogs,
                };

                res.json(responseObj);
            }
        } else {
            console.log('User does NOT exist');
            return res.status(400).json('User does NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}