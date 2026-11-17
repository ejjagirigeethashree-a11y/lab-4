const jwt = require('jsonwebtoken');
require('dotenv').config();

/**
 * Authentication Middleware:
 * Inspects incoming request headers for a Bearer token,
 * validates the JWT signature, and attaches the user payload to the request object.
 */
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  let jwtToken;

  if (authHeader !== undefined) {
    // Expected format: "Bearer <jwt_token>"
    jwtToken = authHeader.split(' ')[1];
  }

  // Reject missing token
  if (!jwtToken) {
    return res.status(401).json({
      error: 'Invalid JWT Token',
    });
  }

  const secretKey = process.env.JWT_SECRET || 'bdf_lab4_default_secret_key';

  jwt.verify(jwtToken, secretKey, (error, payload) => {
    if (error) {
      // Reject invalid or expired token
      return res.status(401).json({
        error: 'Invalid JWT Token',
      });
    }

    // Attach decoded token payload (containing only username) to request
    req.user = payload;
    next();
  });
};

module.exports = {
  authenticateToken,
};
