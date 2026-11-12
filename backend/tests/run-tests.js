/**
 * Automated Test Suite for TravelMate REST API (Lab Task 3)
 */
const http = require('http');
const createApp = require('../src/app');
const config = require('../src/config');

const app = createApp();
const PORT = 3001; // Use separate port for tests to avoid collision

function request(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: '127.0.0.1',
        port: PORT,
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(options.headers || {}),
        },
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          let json = null;
          try {
            json = JSON.parse(body);
          } catch (_) {
            json = body;
          }
          resolve({ status: res.statusCode, headers: res.headers, body: json });
        });
      }
    );

    req.on('error', reject);

    if (data) {
      req.write(typeof data === 'string' ? data : JSON.stringify(data));
    }
    req.end();
  });
}

let passed = 0;
let failed = 0;

function assert(condition, message) {
  if (condition) {
    console.log(`  ✓ ${message}`);
    passed++;
  } else {
    console.error(`  ✗ FAIL: ${message}`);
    failed++;
  }
}

async function runTests() {
  const server = app.listen(PORT, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  console.log(`\n🧪 Starting TravelMate Backend Automated Tests on port ${PORT}...\n`);

  try {
    // 1. Health check
    console.log('1. Testing Health Endpoint:');
    const healthRes = await request({ path: '/api/health', method: 'GET' });
    assert(healthRes.status === 200, 'GET /api/health returns 200 OK');
    assert(healthRes.body.success === true, 'Response has success: true');
    assert(healthRes.body.data.status === 'UP', 'Status is UP');

    // 2. Auth validation
    console.log('\n2. Testing Auth Validation:');
    const badReg = await request({ path: '/api/auth/register', method: 'POST' }, { email: 'bad' });
    assert(badReg.status === 400, 'Registration with invalid fields returns 400');
    assert(badReg.body.success === false, 'Error response has success: false');

    // 3. Register a new user
    console.log('\n3. Testing User Registration:');
    const testEmail = `traveler_${Date.now()}@test.com`;
    const regRes = await request(
      { path: '/api/auth/register', method: 'POST' },
      { name: 'Alice Traveler', email: testEmail, password: 'securePassword123' }
    );
    assert(regRes.status === 201, 'POST /api/auth/register returns 201 Created');
    assert(regRes.body.success === true, 'Registration success is true');
    assert(Boolean(regRes.body.data.token), 'JWT token returned on registration');
    assert(regRes.body.data.user.email === testEmail, 'User email matches registered email');
    assert(!regRes.body.data.user.passwordHash, 'Password hash is NOT exposed in response');

    // 4. Duplicate registration prevention
    console.log('\n4. Testing Duplicate Registration:');
    const dupRes = await request(
      { path: '/api/auth/register', method: 'POST' },
      { name: 'Alice Duplicate', email: testEmail, password: 'securePassword123' }
    );
    assert(dupRes.status === 409, 'Duplicate email registration returns 409 Conflict');

    // 5. User login
    console.log('\n5. Testing User Login:');
    const loginRes = await request(
      { path: '/api/auth/login', method: 'POST' },
      { email: testEmail, password: 'securePassword123' }
    );
    assert(loginRes.status === 200, 'POST /api/auth/login returns 200 OK');
    assert(loginRes.body.success === true, 'Login success is true');
    const token = loginRes.body.data.token;
    assert(Boolean(token), 'JWT token returned on login');

    // 6. Invalid password login
    console.log('\n6. Testing Invalid Login:');
    const badLogin = await request(
      { path: '/api/auth/login', method: 'POST' },
      { email: testEmail, password: 'wrongPassword!' }
    );
    assert(badLogin.status === 401, 'Invalid password returns 401 Unauthorized');

    // 7. Protected route without token
    console.log('\n7. Testing Protected Route Without Token:');
    const unauthRes = await request({ path: '/api/auth/me', method: 'GET' });
    assert(unauthRes.status === 401, 'Accessing /api/auth/me without token returns 401');

    // 8. Protected route with token
    console.log('\n8. Testing Protected Route With Token:');
    const authMeRes = await request({
      path: '/api/auth/me',
      method: 'GET',
      headers: { Authorization: `Bearer ${token}` },
    });
    assert(authMeRes.status === 200, 'GET /api/auth/me with Bearer token returns 200 OK');
    assert(authMeRes.body.data.email === testEmail, 'User email matches token user');

    // 9. Update profile
    console.log('\n9. Testing Profile Update:');
    const updateProfileRes = await request(
      {
        path: '/api/users/me',
        method: 'PUT',
        headers: { Authorization: `Bearer ${token}` },
      },
      { name: 'Alice Explorer Updated' }
    );
    assert(updateProfileRes.status === 200, 'PUT /api/users/me returns 200 OK');
    assert(updateProfileRes.body.data.name === 'Alice Explorer Updated', 'Name successfully updated');

    // 10. Destinations List
    console.log('\n10. Testing Destinations Endpoints:');
    const destListRes = await request({ path: '/api/destinations', method: 'GET' });
    assert(destListRes.status === 200, 'GET /api/destinations returns 200 OK');
    assert(Array.isArray(destListRes.body.data), 'Destinations returned as array');
    assert(destListRes.body.data.length >= 3, 'Initial destinations loaded from JSON storage');

    // 11. Popular Destinations
    console.log('\n11. Testing Popular Destinations:');
    const popRes = await request({ path: '/api/destinations/popular', method: 'GET' });
    assert(popRes.status === 200, 'GET /api/destinations/popular returns 200 OK');
    assert(popRes.body.data.every((d) => d.isPopular === true), 'All popular destinations have isPopular: true');

    // 12. Destination by ID
    console.log('\n12. Testing Destination By ID:');
    const firstId = destListRes.body.data[0].id;
    const destItemRes = await request({ path: `/api/destinations/${firstId}`, method: 'GET' });
    assert(destItemRes.status === 200, `GET /api/destinations/${firstId} returns 200 OK`);
    assert(destItemRes.body.data.id === firstId, 'Destination ID matches');

    // 13. Create Destination
    console.log('\n13. Testing Destination Creation:');
    const createDestRes = await request(
      { path: '/api/destinations', method: 'POST' },
      {
        name: 'Kuakata Beach',
        country: 'Bangladesh',
        subtitle: 'Daughter of the sea',
        description: 'A panoramic sea beach where you can watch both sunrise and sunset.',
        icon: 'beach_access',
        isPopular: true,
      }
    );
    assert(createDestRes.status === 201, 'POST /api/destinations returns 201 Created');
    const createdId = createDestRes.body.data.id;
    assert(createDestRes.body.data.name === 'Kuakata Beach', 'Created destination name matches');

    // 14. Update Destination
    console.log('\n14. Testing Destination Update:');
    const updateDestRes = await request(
      { path: `/api/destinations/${createdId}`, method: 'PUT' },
      { subtitle: 'Daughter of the sea - Sunrise & Sunset' }
    );
    assert(updateDestRes.status === 200, `PUT /api/destinations/${createdId} returns 200 OK`);
    assert(updateDestRes.body.data.subtitle === 'Daughter of the sea - Sunrise & Sunset', 'Subtitle updated');

    // 15. Delete Destination
    console.log('\n15. Testing Destination Deletion:');
    const deleteDestRes = await request({ path: `/api/destinations/${createdId}`, method: 'DELETE' });
    assert(deleteDestRes.status === 200, `DELETE /api/destinations/${createdId} returns 200 OK`);

    const verifyDeleted = await request({ path: `/api/destinations/${createdId}`, method: 'GET' });
    assert(verifyDeleted.status === 404, 'Deleted destination returns 404 Not Found');

    console.log('\n====================================================');
    console.log(`Test Results: ${passed} PASSED, ${failed} FAILED`);
    console.log('====================================================\n');

    if (failed > 0) {
      process.exitCode = 1;
    }
  } catch (err) {
    console.error('Fatal test error:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTests();
