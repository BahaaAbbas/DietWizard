const express = require('express');
const router = express.Router();
const path = require('path');

const session = require('express-session');
const cookieParser = require('cookie-parser');


 

exports.getStartpage=async(req,res)=>{

    if (req.session.user) {
 
        // app.use(home);
        res.redirect('/Home');
    } else {
 
        // res.render('Login');
        // app.use(userslogin);
        res.redirect('/Login'); 
    }
};
