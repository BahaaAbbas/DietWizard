const express = require("express");
const router = express.Router();
const AddPost = require("../controllers/addpost");
 
const multer = require('multer');

 

const upload = multer({ dest: 'uploads/' });
 



router.post('/posts',upload.single('image'), AddPost.Add); 

router.put('/posts/:idPost/likes/:UserLike',AddPost.getlike);  


router.post('/posts/:idPost/comments' , AddPost.getcomment); 


router.delete('/deleteposts/:idPost', AddPost.deletePost);



router.delete('/posts/:idPost/comments/:commentIndex', AddPost.deleteComment);

router.put('/editposts/:idPost', AddPost.editPost);



router.get('/posts', AddPost.getposts); 


router.post('/posts/report/:idPost' , AddPost.reportPost); 
router.get('/posts/getreport/' , AddPost.getReportposts); 
router.put('/editreportposts/:idPost', AddPost.editReportPost);//for admin only

module.exports = router;



 