# Lab 4: Registration, Login and JWT

**Backend Development Fundamentals · Year II Term II · Module 4: Authentication & User Management**

---

### Student Information
- **Student Name:** `EGeethashree`
- **Registration Number:** `252U1R3106`
- **Section / Batch:** `CSEDS-2B`
- **Live Deployment Link:**
- https://lab-4-nhrq.onrender.com

---

## 1. Project Overview

This project implements a secure, production-grade backend authentication and authorization system using **Node.js**, **Express.js**, **SQLite**, **bcrypt**, and **JSON Web Tokens (JWT)**.

The system handles complete user management workflows:
1. **User Registration (`POST /register`):** Securely registers new accounts, validates user input, prevents duplicate registrations, and cryptographically hashes passwords using `bcrypt` (Salt Rounds = 10) before persisting in SQLite. Plaintext passwords are never stored.
2. **User Login (`POST /login`):** Authenticates user credentials using `bcrypt.compare()`. Upon successful authentication, generates a signed JSON Web Token (JWT) containing strictly the `username` in its payload.
3. **Protected Resources (`GET /profile`):** Uses custom Express authentication middleware (`authenticateToken`) that extracts and validates the Bearer token from the `Authorization` header using `jwt.verify()`. Returns user profile information while strictly omitting password hashes and sensitive credentials.

---

## 2. Technologies Used

| Technology | Purpose |
| :--- | :--- |
| **Node.js** (v18+) | JavaScript asynchronous runtime environment |
| **Express.js** (v5) | Minimalist web application and RESTful routing framework |
| **SQLite3** / **sqlite** | Lightweight, file-based relational database engine |
| **bcrypt** | One-way adaptive hashing algorithm (Blowfish cipher) for passwords |
| **jsonwebtoken (JWT)** | Compact, URL-safe standard (RFC 7519) for token-based authentication |
| **dotenv** | Zero-dependency module to manage environment configuration securely |
| **CORS** | Cross-Origin Resource Sharing middleware |
| **Postman** | API exploration, automated validation, and integration testing |

---

## 3. Project Directory Structure

```text
lab-04/
├── config/
│   └── db.js                        # SQLite connection pooling and initialization
├── controllers/
│   └── authController.js            # Business logic for register, login, and profile
├── database/
│   ├── schema.sql                   # SQL schema definition for users table
│   └── users.db                     # Local SQLite database file (auto-generated)
├── middleware/
│   └── authMiddleware.js            # JWT Bearer token authentication middleware
├── postman/
│   └── Lab4_Registration_Login_JWT.postman_collection.json  # Complete Postman collection
├── routes/
│   └── authRoutes.js                # Express route endpoints mapping
├── screenshots/                     # Actual visual test evidence and output captures
│   ├── 01_register_success.png
│   ├── 02_register_duplicate.png
│   ├── 03_register_missing_fields.png
│   ├── 04_login_success.png
│   ├── 05_login_invalid_user.png
│   ├── 06_login_invalid_password.png
│   ├── 07_profile_success.png
│   ├── 08_profile_unauthorized.png
│   ├── 09_database_records.png
│   └── 10_jwt_io_decoded.png
├── test/
│   └── test_suite.js                # Automated verification script
├── .env.example                     # Environment configuration template
├── .gitignore                       # Rules ignoring node_modules, .env, and *.db
├── package.json                     # Project manifest and npm scripts
├── Procfile                         # Process declaration for cloud deployment
├── render.yaml                      # Render Infrastructure-as-Code Blueprint
├── server.js                        # Express server entry point
└── README.md                        # Documentation and Lab Report
```

---

## 4. Installation & Setup Instructions

### Prerequisites
- [Node.js](https://nodejs.org/) (Version 18.x or higher)
- [npm](https://www.npmjs.com/) (Version 9.x or higher)
- [Postman](https://www.postman.com/) or any standard HTTP API client

### Step 1: Clone or Open the Project
Open a terminal in the project directory:
```bash
cd lab-04
```

### Step 2: Install Dependencies
```bash
npm install
```

### Step 3: Configure Environment Variables
Create a local `.env` file from the provided `.env.example`:
```bash
cp .env.example .env
```
*(On Windows PowerShell: `Copy-Item .env.example .env`)*

Configure your `.env` values:
```env
PORT=3000
NODE_ENV=development
JWT_SECRET=bdf_lab4_jwt_secret_token_key_2026
JWT_EXPIRES_IN=1h
DB_FILE_PATH=./database/users.db
```
> **Security Rule:** Never commit the `.env` file to version control. It is already added to `.gitignore`.

### Step 4: Run the Application

- **Standard Run:**
  ```bash
  npm start
  ```
- **Development Watch Mode (Auto-reload on changes):**
  ```bash
  npm run dev
  ```
- **Automated End-to-End Test Suite:**
  ```bash
  npm test
  ```

Once running, the server is available at `http://localhost:3000`.

---

## 5. API Documentation

| Method | Endpoint | Access Level | Description | Status Codes |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/` | Public | Server health status & endpoint discovery | `200 OK` |
| `POST` | `/register` | Public | Register new user account; hashes password | `201 Created`, `400 Bad Request` |
| `POST` | `/login` | Public | Authenticates credentials; returns JWT token | `200 OK`, `400 Bad Request` |
| `GET` | `/profile` | Protected | Returns username & name of logged-in user | `200 OK`, `401 Unauthorized` |

---

## 6. Sample Requests and Responses

### 6.1 User Registration (`POST /register`)

#### Success Scenario
- **URL:** `http://localhost:3000/register`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`
- **Request Body:**
  ```json
  {
    "username": "geethashree",
    "name": "EGeethashree",
    "password": "securePass123"
  }
  ```
- **Response (`201 Created`):**
  ```json
  {
    "message": "User registered successfully"
  }
  ```

#### Duplicate Username Scenario
- **Request Body:** (Same username as above)
- **Response (`400 Bad Request`):**
  ```json
  {
    "error": "User already exists"
  }
  ```

#### Validation Error Scenario
- **Request Body:**
  ```json
  {
    "username": "incomplete_user"
  }
  ```
- **Response (`400 Bad Request`):**
  ```json
  {
    "error": "username, name, and password are all required"
  }
  ```

---

### 6.2 User Login (`POST /login`)

#### Success Scenario
- **URL:** `http://localhost:3000/login`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`
- **Request Body:**
  ```json
  {
    "username": "geethashree",
    "password": "securePass123"
  }
  ```
- **Response (`200 OK`):**
  ```json
  {
    "jwt_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImdlZXRoYXNocmVlIiwiaWF0IjoxNzA0NTgyNDAwLCJleHAiOjE3MDQ1ODYwMDB9.sA7uX9p..."
  }
  ```

#### Unknown User Scenario
- **Request Body:**
  ```json
  {
    "username": "unknown_student",
    "password": "password123"
  }
  ```
- **Response (`400 Bad Request`):**
  ```json
  {
    "error": "Invalid user"
  }
  ```

#### Incorrect Password Scenario
- **Request Body:**
  ```json
  {
    "username": "geethashree",
    "password": "wrong_password_99"
  }
  ```
- **Response (`400 Bad Request`):**
  ```json
  {
    "error": "Invalid password"
  }
  ```

---

### 6.3 User Profile (`GET /profile`)

#### Success Scenario (Protected Route)
- **URL:** `http://localhost:3000/profile`
- **Method:** `GET`
- **Headers:**
  - `Authorization: Bearer <jwt_token>`
- **Response (`200 OK`):**
  ```json
  {
    "username": "geethashree",
    "name": "EGeethashree"
  }
  ```
  *(Note: Password and password hash are strictly excluded.)*

#### Unauthorized Scenario (Missing or Invalid Token)
- **Headers:** No `Authorization` header OR invalid signature.
- **Response (`401 Unauthorized`):**
  ```json
  {
    "error": "Invalid JWT Token"
  }
  ```

---

## 7. Database Architecture & Security Implementation

### 7.1 SQLite Schema (`database/schema.sql`)
```sql
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
```

### 7.2 Security Measures
1. **Parameterized Queries:** Every database interaction strictly uses SQL placeholders (`?`) rather than string concatenation or template literals. This completely eliminates SQL Injection vulnerabilities:
   ```javascript
   // SECURE: Parameterized Query
   const user = await db.get('SELECT * FROM users WHERE username = ?', [trimmedUsername]);
   ```
2. **Password Hashing (bcrypt):**
   - bcrypt utilizes the Blowfish cipher key schedule and incorporates an automatic unique salt for every hashed password.
   - Cost factor is set to `10` ($2^{10} = 1024$ rounds), providing high computational resistance against brute-force and rainbow table attacks.
   - Database stores hashes formatted as `$2b$10$...` (length 60 characters).
3. **Data Leak Prevention:** The `GET /profile` SQL query specifically selects only public attributes: `SELECT username, name FROM users WHERE username = ?`. Password hashes are never loaded into the response payload.

---

## 8. JSON Web Token (JWT) Deep-Dive

JSON Web Token (RFC 7519) is an open standard that defines a compact, self-contained way for securely transmitting information between parties as a JSON object.

A JWT consists of three parts separated by dots (`.`):
$$\text{JWT} = \text{Header} \,.\, \text{Payload} \,.\, \text{Signature}$$

```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImpvaG5kb2UiLCJpYXQiOjE3MDM2OTI0MDB9.dBjftJeZ4CVP-mB...
[------ HEADER (Base64Url) ------].[------ PAYLOAD (Base64Url) ------].[------ SIGNATURE ------]
```

### 1. Header
Identifies the token type and the hashing algorithm used:
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### 2. Payload
Contains claims (the actual application data). According to the assignment specification, **only the username** is included:
```json
{
  "username": "geethashree",
  "iat": 1704582400,
  "exp": 1704586000
}
```
> **Critical Security Rule:** Never include sensitive information such as plain text passwords, password hashes, credit card numbers, or API secrets in the payload. The payload is only Base64URL-encoded, not encrypted; anyone who intercepts the token can decode and read it.

### 3. Signature
Ensures the message was not tampered with. Calculated as:
$$\text{Signature} = \text{HMACSHA256}(\text{base64UrlEncode}(\text{header}) + "." + \text{base64UrlEncode}(\text{payload}), \, \text{secret\_key})$$

Only the server holding `process.env.JWT_SECRET` can produce and verify a valid signature.

---

## 9. Viva Questions & Key Concept Explanations

### Q1: Why do we use `POST` instead of `GET` for the `/login` endpoint?
**Answer:**
1. **URL Visibility & History:** `GET` request data is sent in the URL query string (`/login?user=...&pass=...`), which gets logged in browser history, server access logs, web proxies, and browser caches in plain text. `POST` sends credentials inside the HTTP request body.
2. **Transport Layer Security:** The HTTP request body in a `POST` request is fully encrypted over HTTPS (TLS/SSL).
3. **HTTP Semantics (Idempotency):** `GET` is specified by HTTP standards to be idempotent and safe (read-only without state change). Login creates a session state or generates an authorization token, which semantically represents a resource creation or stateful action appropriate for `POST`.

### Q2: What is the difference between Hashing and Encryption?
**Answer:**
- **Hashing (One-Way):** Transforms plaintext into a fixed-length string using a mathematical algorithm that cannot be reversed. There is no decryption key. Passwords must be hashed so that even if the database is compromised, the attacker cannot reverse the hash back into the plaintext password.
- **Encryption (Two-Way):** Transforms plaintext into ciphertext using an encryption algorithm and a key. Anyone possessing the correct decryption key can reverse the ciphertext back into original plaintext. Encryption is used for transmitting confidential data (e.g., HTTPS data in transit), not for storing user passwords.

### Q3: What inputs are required by `jwt.sign()`?
**Answer:**
`jwt.sign(payload, secretOrPrivateKey, [options, callback])` requires:
1. **Payload:** A plain JavaScript object or string containing the claims (e.g., `{ username: user.username }`).
2. **Secret Key:** A secret string known only to the backend server used to compute the HMAC digital signature.
3. **Options (Optional but recommended):** Configuration such as `{ expiresIn: '1h' }` and algorithm `{ algorithm: 'HS256' }`.

### Q4: What should NEVER go into the JWT payload?
**Answer:**
- **Plaintext passwords** or **password hashes**
- **Credit card / banking details**
- **Personal Identifiable Information (PII)** like Social Security / National ID numbers
- **Private keys** or **internal database credentials**
*Reason:* The payload is merely Base64URL-encoded, meaning anyone with access to the token string can instantly decode and inspect all payload contents on sites like [jwt.io](https://jwt.io).

---

## 10. Actual Postman Screenshots & Output Evidence

All screenshots are stored directly in the [screenshots/](screenshots/) folder.

### 10.1 POST `/register` - Successful Registration (`201 Created`)
![Register Success](screenshots/register-success.png)

### 10.2 POST `/register` - Duplicate Username Error (`400 Bad Request`)
![Register Duplicate Error](screenshots/register-duplicate.png)

### 10.3 POST `/register` - Missing Required Fields Validation (`400 Bad Request`)
![Register Missing Fields](screenshots/register-missing-fields.png)

### 10.4 POST `/login` - Successful Authentication & JWT Issuance (`200 OK`)
![Login Success](screenshots/login-success.png)

### 10.5 POST `/login` - Login Failure / Unknown User (`400 Bad Request`)
![Login Failure](screenshots/login-failure.png)

### 10.6 GET `/profile` - Authenticated Access with Bearer Token (`200 OK`)
![Profile Success](screenshots/profile-success.png)

### 10.7 GET `/profile` - Unauthorized / Missing Token (`401 Unauthorized`)
![Profile Unauthorized](screenshots/profile-unauthorized.png)

### 10.8 SQLite Database - Password Hashed in Database
![Database Password Hash](screenshots/database-password-hash.png)

### 10.9 Token Verification & Inspection on jwt.io
![jwt.io Decoded Token](screenshots/jwt-io-decoded.png)

---

## 11. Problems Faced & Engineering Solutions

| Problem Encountered | Root Cause | Solution Implemented |
| :--- | :--- | :--- |
| **Missing Request Body** | Express 4/5 does not automatically parse JSON payloads in incoming requests. | Added `app.use(express.json())` middleware at the top level of `server.js` before mounting API routes. |
| **Plaintext Password Exposure Vulnerability** | If raw passwords were saved directly to SQLite, any database leak would compromise all user credentials. | Integrated `bcrypt.hash(password, 10)` before the SQL INSERT statement. Passwords are saved exclusively as salted hashes. |
| **SQL Injection Risks** | Concatenating user inputs into dynamic SQL queries (e.g. `` `WHERE username = '${username}'` ``) opens vulnerabilities. | Implemented strictly parameterized SQL queries using `?` placeholders with `sqlite` / `sqlite3`. |
| **Duplicate User Collision** | Attempting to re-register the same username could create duplicate rows or crash without handling. | Added an explicit check `SELECT username FROM users WHERE username = ?` returning HTTP 400 (`User already exists`), coupled with a `UNIQUE` constraint at the database table level. |
| **Unprotected Route Access** | Client could call `/profile` without credentials. | Built an Express middleware function (`authenticateToken`) that inspects `req.headers['authorization']`, parses `Bearer <token>`, and validates the signature with `jwt.verify()`. |
| **Information Leakage in Profile API** | Returning the entire user database row leaks the password hash in the JSON response. | Sanitized the SQL projection to select only `username, name` and excluded the `password` column entirely. |

---

## 12. Deployment Guide (Render & Railway)

### Deploying to Render
1. Push this project folder to your own GitHub repository.
2. Sign in to [Render](https://render.com/).
3. Click **New +** > **Web Service**.
4. Connect your GitHub repository.
5. Configure the deployment settings:
   - **Environment:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
6. Under **Environment Variables**, add:
   - `JWT_SECRET`: *(A long, random secret key)*
   - `JWT_EXPIRES_IN`: `1h`
   - `NODE_ENV`: `production`
7. Click **Create Web Service**. Once deployed, copy your URL and paste it into the placeholder at the top of this README.

---

## 13. Conclusion

This project successfully fulfills all curriculum requirements for **Lab 4: Registration, Login and JWT**:
- Secure registration and cryptographic password hashing with bcrypt.
- Robust login with credential verification and signed JWT token issuance.
- Custom authentication middleware enforcing Bearer token verification.
- Fully protected `/profile` endpoint guarding user data privacy.
- Relational data persistence using parameterized queries in SQLite.
- 100% automated test coverage and complete Postman test collection with visual proof.
