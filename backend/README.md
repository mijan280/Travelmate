# TravelMate REST API Backend (Lab Task 3)

A robust Node.js and Express.js REST API backend with JSON file-based persistent storage, Clean Architecture, and the Repository Pattern for the TravelMate Flutter application.

---

## 1. Architecture Overview

The backend uses a layered architecture with complete separation of concerns:

```text
Flutter App / Mobile Client
        │  (HTTP / JSON)
        ▼
   Express App (src/app.js)
        │
   Middleware (Logger, Body Parsers, CORS, JWT Auth, Validators)
        │
   Express Routers (src/routes/)
        │
   Controllers (src/controllers/)
        │
   Services (src/services/)
        │
   Repositories (src/repositories/)
        │
   Storage Adapter Interface (IStorageAdapter)
        │
   JsonStorageAdapter (src/storage/json/)
        │  (Safe atomic writes with file locking)
        ▼
   JSON Data Files (backend/data/*.json)
```

### Key Design Benefits:
1. **Zero Database Setup Needed Today**: Uses JSON files in `backend/data/` so you can run the backend immediately without configuring MySQL, MongoDB, or PostgreSQL.
2. **Future Database Migration**: The Repository layer depends only on `IStorageAdapter`. To migrate to MySQL, MongoDB, SQLite, or PostgreSQL in the future, simply implement a new storage adapter without touching routes, controllers, services, or Flutter UI.

---

## 2. Directory Structure

```text
backend/
├── src/
│   ├── config/
│   │   └── index.js              # Environment and port configuration
│   ├── controllers/
│   │   ├── auth.controller.js     # Register, Login, Get Current User
│   │   ├── destination.controller.js # CRUD for destinations
│   │   ├── health.controller.js   # Server health check
│   │   └── user.controller.js     # User profile retrieval & update
│   ├── middleware/
│   │   ├── auth.middleware.js     # JWT Bearer token authentication
│   │   ├── errorHandler.middleware.js # Centralized 404 & 500 error handlers
│   │   ├── requestLogger.middleware.js # Terminal request logger
│   │   └── validate.middleware.js # Input validation runner
│   ├── models/
│   │   ├── Destination.js         # Destination domain entity
│   │   └── User.js                # User domain entity (safe JSON omitting passwordHash)
│   ├── repositories/
│   │   ├── destinationRepository.js # Destination data queries & mutations
│   │   └── userRepository.js        # User data queries & mutations
│   ├── routes/
│   │   ├── auth.routes.js         # /api/auth routes
│   │   ├── destination.routes.js  # /api/destinations routes
│   │   ├── health.routes.js       # /api/health route
│   │   ├── index.js               # Master router wiring dependencies
│   │   └── user.routes.js         # /api/users routes
│   ├── services/
│   │   ├── authService.js         # Bcrypt hashing & JWT token issuing
│   │   ├── destinationService.js  # Business logic for destinations
│   │   └── userService.js         # Business logic for user management
│   ├── storage/
│   │   ├── interfaces/
│   │   │   └── IStorageAdapter.js # Abstract storage contract
│   │   └── json/
│   │       └── JsonStorageAdapter.js # Safe atomic JSON file storage
│   ├── utils/
│   │   ├── fileLock.util.js       # Mutex queue to prevent concurrent write corruption
│   │   ├── response.util.js       # Standardized success/error JSON response builder
│   │   └── token.util.js          # JWT sign and verify helpers
│   ├── app.js                     # Express application factory
│   └── server.js                  # Entry point listening on 0.0.0.0:3000
│
├── data/
│   ├── destinations.json          # Persistent destination records
│   └── users.json                 # Persistent user records with bcrypt hashes
│
├── tests/
│   └── run-tests.js               # 33 automated integration tests
│
├── .env.example
├── .env
├── .gitignore
├── package.json
└── README.md
```

---

## 3. Implemented REST API Endpoints

### Health Check
- `GET /api/health` — Checks server operational status and uptime.

### Authentication
- `POST /api/auth/register` — Registers a new user with bcrypt password hashing. Returns JWT token.
- `POST /api/auth/login` — Authenticates user credentials with bcrypt comparison. Returns JWT token.
- `GET /api/auth/me` — Retrieves authenticated user profile (`Authorization: Bearer <token>`).

### User Management
- `GET /api/users/me` — Retrieves current user profile (`Authorization: Bearer <token>`).
- `PUT /api/users/me` — Updates current user name (`Authorization: Bearer <token>`).

### Destinations
- `GET /api/destinations` — Retrieves all destinations (supports `?search=<term>` query).
- `GET /api/destinations/popular` — Retrieves popular destinations for the Home screen.
- `GET /api/destinations/:id` — Retrieves specific destination by ID.
- `POST /api/destinations` — Creates a new destination in persistent storage.
- `PUT /api/destinations/:id` — Updates an existing destination.
- `DELETE /api/destinations/:id` — Deletes a destination from persistent storage.

---

## 4. API Request & Response Examples

### Standard Response Envelope
All API responses follow a consistent JSON format:

```json
// Success Response:
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": { ... }
}

// Error Response:
{
  "success": false,
  "message": "Invalid email or password",
  "data": null
}
```

### Registration Request
`POST /api/auth/register`
```json
{
  "name": "Alice Traveler",
  "email": "alice@travelmate.com",
  "password": "password123"
}
```
**Response (201 Created):**
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": {
      "id": "1794206350714",
      "name": "Alice Traveler",
      "email": "alice@travelmate.com",
      "role": "traveler",
      "createdAt": "2026-11-09T12:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Login Request
`POST /api/auth/login`
```json
{
  "email": "demo@travelmate.com",
  "password": "password123"
}
```
**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "1001",
      "name": "TravelMate Traveler",
      "email": "demo@travelmate.com",
      "role": "traveler",
      "createdAt": "2026-10-16T10:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

## 5. How to Run the Backend

### Prerequisites
- Node.js v18+ (tested on v22.20.0)
- npm v9+

### Quick Start
```bash
# Navigate to the backend directory
cd backend

# Install dependencies (already installed)
npm install

# Start development server with auto-reload
npm run dev

# Or start standard production server
npm start
```

### Running Automated Tests
```bash
npm test
```
Runs 33 automated tests covering health checks, auth validation, registration, duplicate checks, login, password security, JWT verification, profile updates, and full destination CRUD.

---

## 6. Future Database Migration Guide

The backend uses the **Repository Pattern** and **Storage Abstraction Layer** (`IStorageAdapter`). 

### Migration Steps (e.g. to MongoDB or MySQL):
1. **Create a new adapter class** in `src/storage/`:
   ```javascript
   // src/storage/mongo/MongoStorageAdapter.js
   const IStorageAdapter = require('../interfaces/IStorageAdapter');
   
   class MongoStorageAdapter extends IStorageAdapter {
     constructor(connectionString) {
       super();
       // initialize connection
     }
     async read(collection) { /* MongoDB find() */ }
     async findById(collection, id) { /* MongoDB findById() */ }
     async insert(collection, item) { /* MongoDB insertOne() */ }
     async update(collection, id, updates) { /* MongoDB updateOne() */ }
     async delete(collection, id) { /* MongoDB deleteOne() */ }
   }
   ```
2. **Switch the adapter** in `src/routes/index.js`:
   ```javascript
   // Change from:
   // const storageAdapter = new JsonStorageAdapter(config.dataDir);
   // To:
   const storageAdapter = new MongoStorageAdapter(config.mongoUri);
   ```
3. **Done!**
   - No controllers need to change.
   - No services need to change.
   - No routes need to change.
   - The Flutter frontend requires **zero changes** because the REST API endpoints and response formats remain identical.
