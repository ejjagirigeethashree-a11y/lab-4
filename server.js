const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { initializeDatabase } = require('./config/db');
const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for external client/Postman access
app.use(cors());

// Parse JSON request bodies
app.use(express.json());

// API Info / Health Check
app.get('/', (req, res) => {
  res.status(200).json({
    project: 'Lab 4: Registration, Login and JWT',
    course: 'Backend Development Fundamentals',
    status: 'online',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: 'GET /',
      register: 'POST /register (Body: username, name, password)',
      login: 'POST /login (Body: username, password)',
      profile: 'GET /profile (Header: Authorization: Bearer <jwt_token>)',
    },
  });
});

// Authentication Routes
app.use('/', authRoutes);

// Catch-all for undefined endpoints
app.use((req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('[Server Error]:', err);
  res.status(500).json({
    error: 'Internal server error',
  });
});

// Start the server after initializing database
const startServer = async () => {
  try {
    await initializeDatabase();
    app.listen(PORT, () => {
      console.log('==================================================');
      console.log(` Lab 4 Server started on port ${PORT}`);
      console.log(` Base URL: http://localhost:${PORT}`);
      console.log(` Health Check: http://localhost:${PORT}/`);
      console.log('==================================================');
    });
  } catch (error) {
    console.error('Fatal: Failed to initialize SQLite database:', error);
    process.exit(1);
  }
};

startServer();

module.exports = app;
