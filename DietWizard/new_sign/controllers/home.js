const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


 

exports.getHome=async(req,res)=>{

    console.log("Session Data:", req.session);
    // res.render('Home');
    if (req.session.user) {
        res.render('Home', { user: req.session.user });
    } else {
        res.redirect('/');

    }
};
