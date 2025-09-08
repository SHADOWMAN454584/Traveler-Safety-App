# Tourist Safety System - API Documentation

## Overview
This is a comprehensive backend API for the Smart Tourist Safety Monitoring & Incident Response System. The API provides full functionality for tourist registration, emergency response, authority monitoring, and safety management.

## Base URL
```
http://localhost:5000
```

## Authentication
The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## API Endpoints

### 🔐 Authentication Endpoints

#### POST /signup
Register a new user (tourist or authority)
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123",
  "userType": "tourist" // or "authority"
}
```

#### POST /signin  
Login user
```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```

#### POST /refresh-token
Refresh JWT token (requires authentication)

### 👤 Tourist Endpoints

#### POST /tourist/register
Register tourist profile (requires authentication)
```json
{
  "fullName": "John Doe",
  "nationality": "USA",
  "passportNumber": "P123456789",
  "phoneNumber": "+1234567890",
  "emergencyContact": {
    "name": "Jane Doe",
    "phone": "+0987654321",
    "relationship": "Spouse"
  },
  "tripDetails": {
    "checkInDate": "2025-09-08",
    "checkOutDate": "2025-09-15",
    "accommodation": "Hotel ABC",
    "purpose": "Tourism"
  }
}
```

#### GET /tourist/profile
Get tourist profile (requires authentication)

#### PUT /tourist/profile
Update tourist profile (requires authentication)

#### POST /tourist/location
Update current location (requires authentication)
```json
{
  "latitude": 28.6139,
  "longitude": 77.2090,
  "address": "New Delhi, India",
  "accuracy": 10
}
```

#### GET /tourist/safety-score
Get current safety score (requires authentication)

### 🚨 Emergency Endpoints

#### POST /emergency/panic
Trigger panic button (requires authentication)
```json
{
  "latitude": 28.6139,
  "longitude": 77.2090,
  "description": "Emergency situation",
  "type": "panic",
  "accuracy": 5
}
```

#### GET /alerts/recent
Get recent alerts for tourist (requires authentication)

#### GET /alerts/broadcasts
Get active broadcast alerts (requires authentication)

### 👮 Authority/Dashboard Endpoints

#### POST /dashboard/login
Authority login with enhanced security
```json
{
  "email": "officer@police.gov.in",
  "password": "securePassword123",
  "badgeNumber": "POL12345"
}
```

#### GET /dashboard/stats
Get dashboard statistics (requires authority authentication)

#### GET /dashboard/alerts
Get all alerts with pagination (requires authority authentication)
- Query parameters: `status`, `severity`, `page`, `limit`

#### PUT /dashboard/alerts/:alertId
Update alert status (requires authority authentication)
```json
{
  "status": "acknowledged", // or "resolved", "false_alarm"
  "notes": "Officer dispatched to location"
}
```

#### POST /dashboard/broadcast
Create broadcast alert (requires authority authentication with broadcast permissions)
```json
{
  "title": "Safety Advisory",
  "message": "Heavy rainfall expected. Please avoid low-lying areas.",
  "type": "warning", // or "info", "emergency"
  "targetArea": {
    "state": "Delhi",
    "district": "Central Delhi",
    "radius": 10000
  },
  "expiresIn": 24 // hours
}
```

#### POST /dashboard/generate-efir
Generate E-FIR for incident (requires authority authentication)
```json
{
  "alertId": "ALT123456ABC",
  "firDetails": {
    "officerRemarks": "Tourist found safe, false alarm",
    "actionTaken": "Counseled tourist about proper emergency procedures"
  }
}
```

### 🏥 Health Check

#### GET /health
System health check
```json
{
  "status": "OK",
  "timestamp": "2025-09-08T10:30:00.000Z",
  "uptime": 3600,
  "mongoStatus": "Connected"
}
```

## Data Models

### User
```json
{
  "_id": "ObjectId",
  "name": "string",
  "email": "string (unique)",
  "password": "string (hashed)",
  "userType": "tourist|authority",
  "createdAt": "Date",
  "lastLogin": "Date",
  "isActive": "boolean"
}
```

### Tourist Profile
```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: User)",
  "digitalId": "string (unique)",
  "fullName": "string",
  "nationality": "string",
  "passportNumber": "string",
  "phoneNumber": "string",
  "emergencyContact": {
    "name": "string",
    "phone": "string", 
    "relationship": "string"
  },
  "currentLocation": {
    "latitude": "number",
    "longitude": "number",
    "address": "string",
    "lastUpdated": "Date"
  },
  "safetyScore": "number (0-100)",
  "isInEmergency": "boolean",
  "tripDetails": {
    "checkInDate": "Date",
    "checkOutDate": "Date",
    "accommodation": "string",
    "purpose": "string"
  },
  "preferences": {
    "language": "string",
    "notifications": "boolean"
  },
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Authority
```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: User)",
  "badgeNumber": "string (unique)",
  "department": "string",
  "rank": "string",
  "jurisdiction": {
    "state": "string",
    "district": "string",
    "area": "string"
  },
  "permissions": {
    "viewAlerts": "boolean",
    "manageAlerts": "boolean",
    "generateReports": "boolean",
    "broadcastAlerts": "boolean"
  },
  "isOnDuty": "boolean",
  "createdAt": "Date"
}
```

### Emergency Alert
```json
{
  "_id": "ObjectId",
  "alertId": "string (unique)",
  "touristId": "ObjectId (ref: Tourist)",
  "type": "panic|medical|theft|lost|general",
  "severity": "low|medium|high|critical",
  "status": "active|acknowledged|resolved|false_alarm",
  "location": {
    "latitude": "number",
    "longitude": "number", 
    "address": "string",
    "accuracy": "number"
  },
  "description": "string",
  "responseTime": "number",
  "assignedOfficer": "ObjectId (ref: Authority)",
  "createdAt": "Date",
  "resolvedAt": "Date",
  "notes": [{
    "officer": "ObjectId (ref: Authority)",
    "note": "string",
    "timestamp": "Date"
  }]
}
```

### Broadcast Alert
```json
{
  "_id": "ObjectId",
  "title": "string",
  "message": "string",
  "type": "warning|info|emergency",
  "targetArea": {
    "state": "string",
    "district": "string",
    "radius": "number"
  },
  "isActive": "boolean",
  "createdBy": "ObjectId (ref: Authority)",
  "createdAt": "Date",
  "expiresAt": "Date"
}
```

## Security Features

### Rate Limiting
- 100 requests per 15-minute window per IP
- Prevents API abuse and DDoS attacks

### JWT Authentication
- 24-hour tokens for tourists
- 8-hour tokens for authorities (enhanced security)
- Secure token refresh mechanism

### Password Security
- bcrypt hashing with salt rounds: 12
- Minimum password requirements enforced

### API Security
- CORS enabled for cross-origin requests
- Request body size limits (10MB)
- Input validation and sanitization
- Error handling without data leakage

## Error Responses

### Standard Error Format
```json
{
  "error": "Error message description"
}
```

### Common HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

## Development Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set environment variables in `.env`:
   ```
   MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/database
   JWT_SECRET=your-secure-jwt-secret
   PORT=5000
   ```

3. Start development server:
   ```bash
   npm run dev
   ```

4. Start production server:
   ```bash
   npm start
   ```

## Production Considerations

### Environment Variables
- Use strong JWT secrets (minimum 32 characters)
- Secure MongoDB connection strings
- Set NODE_ENV=production

### Database Indexes
- Create indexes on frequently queried fields
- Compound indexes for complex queries
- Geospatial indexes for location-based queries

### Monitoring
- Implement logging with winston or similar
- Set up monitoring with tools like New Relic
- Configure health checks for load balancers

### Scalability
- Implement Redis for session management
- Add database connection pooling
- Consider microservices architecture for large scale

This API provides a complete foundation for a production-ready tourist safety system with comprehensive functionality for emergency response, monitoring, and management.
