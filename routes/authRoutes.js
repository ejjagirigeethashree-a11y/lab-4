const express = require('express');
const router = express.Router();

const {
  registerUser,
  loginUser,
  getUserProfile,
} = require('../controllers/authController');

const { authenticateToken } = require('../middleware/authMiddleware');

// 1. User Registration
router.post('/register', registerUser);

// 2. User Login & Token Generation
router.post('/login', loginUser);

// 3. Protected Profile Endpoint
router.get('/profile', authenticateToken, getUserProfile);

module.exports = router;
