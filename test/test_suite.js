const assert = require('assert');
const path = require('path');
const fs = require('fs');
const http = require('http');
const jwt = require('jsonwebtoken');
const sqlite3 = require('sqlite3');
const { open } = require('sqlite');

// Configure test environment
process.env.PORT = '4001';
process.env.DB_FILE_PATH = path.join(__dirname, 'test_users.db');
process.env.JWT_SECRET = 'test_secret_key_lab_4_super_secure';
process.env.JWT_EXPIRES_IN = '1h';

// Remove existing test DB if any
if (fs.existsSync(process.env.DB_FILE_PATH)) {
  fs.unlinkSync(process.env.DB_FILE_PATH);
}

const { initializeDatabase, getDatabase } = require('../config/db');
const app = require('../server');

// Helper to make HTTP requests
const makeRequest = (options, postData = null) => {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = data ? JSON.parse(data) : {};
          resolve({ status: res.statusCode, headers: res.headers, body: parsed, rawBody: data });
        } catch (e) {
          resolve({ status: res.statusCode, headers: res.headers, body: data, rawBody: data });
        }
      });
    });

    req.on('error', (err) => reject(err));

    if (postData) {
      req.write(typeof postData === 'string' ? postData : JSON.stringify(postData));
    }
    req.end();
  });
};

const runTests = async () => {
  console.log('\n======================================================');
  console.log(' RUNNING AUTOMATED TEST SUITE: LAB 4 AUTHENTICATION');
  console.log('======================================================\n');

  let passed = 0;
  let failed = 0;

  const test = async (name, fn) => {
    try {
      await fn();
      console.log(`  [PASS] ${name}`);
      passed++;
    } catch (err) {
      console.error(`  [FAIL] ${name}`);
      console.error(`         ${err.stack || err.message}`);
      failed++;
    }
  };

  // Wait a moment for server to listen
  await new Promise((resolve) => setTimeout(resolve, 800));

  let savedJwtToken = '';

  // 1. Health check
  await test('GET / returns 200 and online status', async () => {
    const res = await makeRequest({
      hostname: '127.0.0.1',
      port: 4001,
      path: '/',
      method: 'GET',
    });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.status, 'online');
  });

  // 2. Register valid user
  await test('POST /register successfully registers a user (201)', async () => {
    const res = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: 4001,
        path: '/register',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      { username: 'geethashree', name: 'EGeethashree', password: 'securePass123' }
    );
    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.message, 'User registered successfully');
  });

  // 3. Reject duplicate username
  await test('POST /register rejects duplicate username with HTTP 400', async () => {
    const res = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: 4001,
        path: '/register',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      { username: 'geethashree', name: 'EGeethashree Duplicate', password: 'differentPassword456' }
    );
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.error, 'User already exists');
  });

  // 4. Missing fields validation
  await test('POST /register validates missing required fields (400)', async () => {
    const res = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: 4001,
        path: '/register',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      { username: 'incomplete' }
    );
    assert.strictEqual(res.status, 400);
    assert.ok(res.body.error);
  });

  // 5. Database verification: Password hash and parameterized query
  await test('Database stores ONLY bcrypt hash, NEVER plain text', async () => {
    const db = await getDatabase();
    const row = await db.get('SELECT * FROM users WHERE username = ?', ['geethashree']);
    assert.ok(row, 'User row should exist in SQLite');
    assert.strictEqual(row.username, 'geethashree');
    assert.strictEqual(row.name, 'EGeethashree');
    assert.notStrictEqual(row.password, 'securePass123', 'Password MUST NOT be plain text');
    assert.ok(row.password.startsWith('$2b$') || row.password.startsWith('$2a$'), 'Password must be valid bcrypt hash');
  });

  // 6. Login valid user
  await test('POST /login authenticates valid user and returns { jwt_token }', async () => {
    const res = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: 4001,
        path: '/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      { username: 'geethashree', password: 'securePass123' }
    );
    assert.strictEqual(res.status, 200);
    assert.ok(res.body.jwt_token, 'Response must include jwt_token');
    savedJwtToken = res.body.jwt_token;
  });

  // 7. Verify JWT Payload structure
  await test('JWT Token payload contains ONLY username (never password)', async () => {
    assert.ok(savedJwtToken, 'JWT Token must exist');
    const decoded = jwt.verify(savedJwtToken, process.env.JWT_SECRET);
    assert.strictEqual(decoded.username, 'geethashree');
    assert.strictEqual(decoded.password, undefined, 'Password MUST NOT be in JWT payload');
    assert.strictEqual(decoded.name, undefined, 'Name not expected in minimalist payload');
  });

  // 8. Login unknown user
  await test('POST /login rejects non-existent user with HTTP 400', async () => {
    const res = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: 4001,
        path: '/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      { username: 'unknown_student', password: 'password123' }
    );
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.error, 'Invalid user');
  });

  // 9. Login wrong password
  await test('POST /login rejects incorrect password with HTTP 400', async () => {
    const res = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: 4001,
        path: '/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      { username: 'geethashree', password: 'wrongPassword_XYZ' }
    );
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.error, 'Invalid password');
  });

  // 10. GET /profile with valid JWT
  await test('GET /profile with valid Bearer token returns username and name (200)', async () => {
    const res = await makeRequest({
      hostname: '127.0.0.1',
      port: 4001,
      path: '/profile',
      method: 'GET',
      headers: {
        Authorization: `Bearer ${savedJwtToken}`,
      },
    });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.username, 'geethashree');
    assert.strictEqual(res.body.name, 'EGeethashree');
    assert.strictEqual(res.body.password, undefined, 'Profile response MUST NOT include password');
  });

  // 11. GET /profile missing token
  await test('GET /profile without token rejects with HTTP 401', async () => {
    const res = await makeRequest({
      hostname: '127.0.0.1',
      port: 4001,
      path: '/profile',
      method: 'GET',
    });
    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.body.error, 'Invalid JWT Token');
  });

  // 12. GET /profile invalid/tampered token
  await test('GET /profile with tampered token rejects with HTTP 401', async () => {
    const res = await makeRequest({
      hostname: '127.0.0.1',
      port: 4001,
      path: '/profile',
      method: 'GET',
      headers: {
        Authorization: 'Bearer tampered.fake.token123',
      },
    });
    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.body.error, 'Invalid JWT Token');
  });

  console.log('\n======================================================');
  console.log(` SUMMARY: ${passed} PASSED, ${failed} FAILED`);
  console.log('======================================================\n');

  // Clean up test DB
  try {
    const db = await getDatabase();
    await db.close();
  } catch (e) {}

  try {
    if (fs.existsSync(process.env.DB_FILE_PATH)) {
      fs.unlinkSync(process.env.DB_FILE_PATH);
    }
  } catch (e) {}

  process.exit(failed > 0 ? 1 : 0);
};

runTests().catch((err) => {
  console.error('Fatal test failure:', err);
  process.exit(1);
});
