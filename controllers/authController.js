const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const { getDatabase } = require('../config/db');

// Cost factor for bcrypt password hashing
const SALT_ROUNDS = 10;

/**
 * Register a new user
 * Method: POST /register
 * Body: { username, name, password }
 */
const registerUser = async (req, res) => {
  try {
    const { username, name, password } = req.body;

    // Validate request body
    if (!username || !name || !password) {
      return res.status(400).json({
        error: 'username, name, and password are all required',
      });
    }

    const trimmedUsername = String(username).trim();
    const trimmedName = String(name).trim();

    if (!trimmedUsername || !trimmedName || !password) {
      return res.status(400).json({
        error: 'Fields cannot be blank or contain only whitespace',
      });
    }

    const db = await getDatabase();

    // Check if user already exists
    const existingUser = await db.get(
      'SELECT username FROM users WHERE username = ?',
      [trimmedUsername]
    );

    if (existingUser) {
      return res.status(400).json({
        error: 'User already exists',
      });
    }

    // Optional validation for password length
    if (password.length < 6) {
      return res.status(400).json({
        error: 'Password must be at least 6 characters long',
      });
    }

    // Hash the password before storing in SQLite
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    // Insert user into SQLite database using parameterized query
    await db.run(
      'INSERT INTO users (username, name, password) VALUES (?, ?, ?)',
      [trimmedUsername, trimmedName, hashedPassword]
    );

    return res.status(201).json({
      message: 'User registered successfully',
    });
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({
      error: 'Internal server error during registration',
    });
  }
};

/**
 * Authenticate existing user and generate JWT
 * Method: POST /login
 * Body: { username, password }
 */
const loginUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Validate request body
    if (!username || !password) {
      return res.status(400).json({
        error: 'Username and password are required',
      });
    }

    const trimmedUsername = String(username).trim();
    const db = await getDatabase();

    // Query user by username
    const user = await db.get(
      'SELECT * FROM users WHERE username = ?',
      [trimmedUsername]
    );

    // Reject unknown users with HTTP 400
    if (!user) {
      return res.status(400).json({
        error: 'Invalid user',
      });
    }

    // Verify password with bcrypt
    const isPasswordMatched = await bcrypt.compare(password, user.password);

    if (!isPasswordMatched) {
      return res.status(400).json({
        error: 'Invalid password',
      });
    }

    // JWT payload MUST contain only the username
    const payload = {
      username: user.username,
    };

    const secretKey = process.env.JWT_SECRET || 'bdf_lab4_default_secret_key';
    const expiresIn = process.env.JWT_EXPIRES_IN || '1h';

    const jwtToken = jwt.sign(payload, secretKey, { expiresIn });

    return res.status(200).json({
      jwt_token: jwtToken,
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      error: 'Internal server error during login',
    });
  }
};

/**
 * Retrieve authenticated user profile
 * Method: GET /profile
 * Header: Authorization: Bearer <jwt_token>
 */
const getUserProfile = async (req, res) => {
  try {
    // req.user is populated by authenticateToken middleware
    const username = req.user?.username;

    if (!username) {
      return res.status(401).json({
        error: 'Invalid JWT Token',
      });
    }

    const db = await getDatabase();
    const user = await db.get(
      'SELECT username, name FROM users WHERE username = ?',
      [username]
    );

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
      });
    }

    // Returns ONLY username and name. NEVER returns passwords or hashes.
    return res.status(200).json({
      username: user.username,
      name: user.name,
    });
  } catch (error) {
    console.error('Profile error:', error);
    return res.status(500).json({
      error: 'Internal server error fetching profile',
    });
  }
};

module.exports = {
  registerUser,
  loginUser,
  getUserProfile,
};
