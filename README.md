# TravelMate — Complete Flutter App & Node.js REST API Backend
## CSE3212 Lab Task 3 Implementation

TravelMate is a modern cross-platform travel discovery application developed with Flutter and connected to a custom Node.js + Express REST API backend with JSON file-based persistent storage, Clean Architecture, and the Repository Pattern.

This project preserves and elevates all features from **Lab Task 1** (form validation, registration, login screens) and **Lab Task 2** (navigation bar, home screen, explore screen, destination detail screen, and profile screen), replacing temporary and hardcoded demo data with real REST API endpoints and persistent storage.

---

## 1. Project Overview

| Property | Detail |
| :--- | :--- |
| **Application Name** | TravelMate |
| **Frontend Framework** | Flutter 3.x / Dart 3.13+ |
| **Backend Framework** | Node.js 22.x + Express.js 4.x |
| **Architecture** | Client-Server REST API with Repository Pattern |
| **Storage Engine** | JSON File-Based Persistent Storage (Atomic Writes) |
| **Authentication** | JWT (JSON Web Tokens) with Bcrypt Password Hashing |
| **Backend Port** | 3000 (Listening on `0.0.0.0`) |
| **Target Platforms** | Android (Physical Device & Emulator), iOS, Desktop |

---

## 2. Architecture & Design Patterns

The project follows clean separation of concerns:

```text
Flutter UI (Screens & Widgets)
        │
Flutter Services (AuthService, DestinationService)
        │
Reusable API Client (ApiClient with Bearer Token Storage)
        │  (HTTP / JSON over Local Wi-Fi or LAN)
        ▼
Express REST API Server (port 3000, 0.0.0.0)
        │
Middleware (Logger, CORS, JSON Body Parser, JWT Auth, Validators)
        │
Express Routers (/api/health, /api/auth, /api/users, /api/destinations)
        │
Controllers (Request handling & response formatting)
        │
Services (Business logic & password hashing)
        │
Repositories (User & Destination data queries)
        │
Storage Adapter Interface (IStorageAdapter)
        │
JsonStorageAdapter (Thread-safe atomic writes to backend/data/)
        │
Persistent JSON Files (users.json, destinations.json)
```

---

## 3. Directory Structure

```text
Flutter/
├── android/                   # Android native project configuration & manifest
├── assets/
│   └── screenshots/           # Lab task demonstration screenshots
├── backend/
│   ├── data/
│   │   ├── destinations.json  # Persistent destinations data
│   │   └── users.json         # Persistent user accounts with bcrypt hashes
│   ├── src/
│   │   ├── config/            # Environment & port configuration
│   │   ├── controllers/       # HTTP request handlers
│   │   ├── middleware/        # JWT auth, validation, error & logging middleware
│   │   ├── models/            # Domain entities (User, Destination)
│   │   ├── repositories/      # Repository layer abstracting storage
│   │   ├── routes/            # Express feature routers
│   │   ├── services/          # Business logic & authentication service
│   │   ├── storage/
│   │   │   ├── interfaces/    # IStorageAdapter contract
│   │   │   └── json/          # JsonStorageAdapter with safe file writes
│   │   ├── utils/             # Mutex lock, JWT tokens, response helpers
│   │   ├── app.js             # Express app builder
│   │   └── server.js          # Server entry point
│   ├── tests/
│   │   └── run-tests.js       # 33 automated integration tests
│   ├── .env.example
│   ├── .env
│   ├── package.json
│   └── README.md
├── lib/
│   ├── models/
│   │   ├── api_response.dart  # Generic ApiResponse<T>
│   │   ├── destination.dart   # Destination model with Flutter IconData mapper
│   │   └── user.dart          # User model
│   ├── screens/
│   │   ├── destination_detail_page.dart # Detail screen
│   │   ├── explore_page.dart  # Explore tab with search & add destination
│   │   ├── home_page.dart     # Home tab with popular destinations
│   │   └── profile_page.dart  # Profile tab with edit profile & logout
│   ├── services/
│   │   ├── api/
│   │   │   ├── api_client.dart     # Central HTTP client with JWT session
│   │   │   ├── api_config.dart     # Centralized IP/Host configuration
│   │   │   └── api_exception.dart  # User-friendly error handling
│   │   ├── auth_service.dart       # Register, login, get profile, update, logout
│   │   └── destination_service.dart# Destinations API service
│   ├── widgets/
│   │   └── destination_card.dart   # Custom card widget
│   ├── login_page.dart        # Real API Login screen with loading & feedback
│   ├── main.dart              # App bootstrap with session auto-restore
│   └── registration_page.dart # Real API Registration screen
├── test/
│   ├── models_and_services_test.dart # Flutter unit tests
│   └── widget_test.dart       # Flutter widget smoke tests
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── DEVELOPMENT_PROGRESS.md
```

---

## 4. Implemented REST API Endpoints

### Health Check
- `GET /api/health` — Returns server health, uptime, and client IP.

### Authentication (`/api/auth`)
- `POST /api/auth/register` — Creates account with validation & bcrypt hashing. Returns JWT.
- `POST /api/auth/login` — Authenticates credentials with bcrypt. Returns JWT.
- `GET /api/auth/me` — Returns current authenticated user profile (`Authorization: Bearer <token>`).

### User Management (`/api/users`)
- `GET /api/users/me` — Retrieves current user profile.
- `PUT /api/users/me` — Updates user profile name.

### Destinations (`/api/destinations`)
- `GET /api/destinations` — Fetches all destinations (supports `?search=<term>` query).
- `GET /api/destinations/popular` — Fetches destinations where `isPopular: true`.
- `GET /api/destinations/:id` — Fetches a single destination by ID.
- `POST /api/destinations` — Creates a new destination in JSON storage.
- `PUT /api/destinations/:id` — Updates an existing destination.
- `DELETE /api/destinations/:id` — Deletes a destination from JSON storage.

---

## 5. Connecting a Physical Android Phone

You can run and test the complete app on your real Android smartphone over local Wi-Fi.

### Step-by-Step Connection Instructions:

1. **Connect both devices to the same Wi-Fi network:**
   - Ensure your development laptop and Android phone are connected to the same Wi-Fi router or laptop mobile hotspot.

2. **Find your laptop's Wi-Fi IPv4 address:**
   - Open PowerShell or Command Prompt on your laptop:
     ```powershell
     ipconfig
     ```
   - Locate the **Wireless LAN adapter Wi-Fi** section.
   - Note the **IPv4 Address** (e.g., `192.168.0.106`).

3. **Verify or update `lib/services/api/api_config.dart`:**
   - Open `lib/services/api/api_config.dart` in VS Code.
   - Ensure `customHostIp` matches your laptop's Wi-Fi IP:
     ```dart
     static String customHostIp = '192.168.0.106'; // Set to your current IPv4
     ```

4. **Start the backend server:**
   - Open a terminal in the `backend` folder:
     ```bash
     cd backend
     npm start
     ```
   - The server will log:
     ```text
     🚀 TravelMate REST API Server Started Successfully
     📡 Listening on: http://0.0.0.0:3000
     📱 Physical Phone URL: http://<YOUR_LAPTOP_IP>:3000/api
     ```

5. **Allow inbound port 3000 in Windows Defender Firewall (Private Network):**
   - Run this PowerShell command as Administrator if connection is blocked:
     ```powershell
     New-NetFirewallRule -DisplayName "TravelMate Backend 3000" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
     ```

6. **Test the connection on your phone's browser:**
   - Open Chrome or any browser on your Android phone and visit:
     ```text
     http://192.168.0.106:3000/api/health
     ```
   - You should see:
     ```json
     {
       "success": true,
       "message": "TravelMate REST API is running and healthy",
       "data": { "status": "UP" }
     }
     ```

7. **Run the Flutter application on your phone:**
   - Enable USB Debugging on your phone and connect via USB cable, or use wireless ADB.
   - In VS Code, select your Android phone as the target device.
   - Run:
     ```bash
     flutter run
     ```

---

## 6. How to Run the Project

### Running the Backend
```bash
cd backend
npm install
npm run dev
```

### Running Backend Integration Tests
```bash
node backend/tests/run-tests.js
```
Runs 33 automated test cases covering authentication, validations, and destination CRUD operations.

### Running Flutter Code Checks & Tests
```bash
flutter pub get
dart format .
dart analyze lib test
flutter test
```

---

## 7. Future Database Migration

The backend is architected using the **Repository Pattern** and an explicit storage contract (`IStorageAdapter`).

Currently, `JsonStorageAdapter` saves data to `backend/data/*.json`.

When you want to migrate to **MySQL**, **MongoDB**, **PostgreSQL**, or **SQLite**:
1. Implement a new class implementing `IStorageAdapter` (e.g., `MongoStorageAdapter.js` or `MySqlStorageAdapter.js`).
2. Update the adapter instantiation in `backend/src/routes/index.js`.
3. That is all! All controllers, services, repositories, and routes remain identical.
4. The Flutter application requires **zero changes** because the REST API contract and endpoints remain 100% the same.
"# Travelmate" 
