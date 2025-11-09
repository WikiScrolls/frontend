# WikiScrolls Frontend API Integration Guide

**Version:** 1.0  
**Last Updated:** November 8, 2025  
**Base URL:** `http://localhost:3000` (development) or your production URL

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Response Format](#response-format)
3. [Error Handling](#error-handling)
4. [Authentication](#authentication)
5. [Rate Limiting](#rate-limiting)
6. [Endpoints](#endpoints)
   - [Authentication](#1-authentication-endpoints)
   - [User Profile](#2-user-profile-endpoints)
   - [Articles](#3-article-endpoints)
   - [Interactions](#4-interaction-endpoints)
   - [Feed](#5-feed-endpoints)
   - [System](#6-system-endpoints)

---

## 🎯 Overview

This guide covers all user-facing endpoints for the WikiScrolls mobile app. Users can:
- Browse and scroll through Wikipedia articles with AI summaries
- Like, save, and view articles
- Manage their profile
- Get personalized feeds
- Track their reading progress

---

## 📦 Response Format

All API responses follow this standard format:

### Success Response
```json
{
  "success": true,
  "message": "Description of the result",
  "data": {
    // Response data here
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "fieldName",
      "message": "Error message for this field"
    }
  ]
}
```

---

## ⚠️ Error Handling

### HTTP Status Codes

| Code | Meaning | When It Happens |
|------|---------|----------------|
| `200` | OK | Request successful |
| `201` | Created | Resource created successfully |
| `204` | No Content | Successful deletion (no response body) |
| `400` | Bad Request | Validation failed or invalid data |
| `401` | Unauthorized | Missing or invalid authentication token |
| `403` | Forbidden | Insufficient permissions |
| `404` | Not Found | Resource doesn't exist |
| `409` | Conflict | Duplicate resource (e.g., email already exists) |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Server Error | Internal server error |

### Common Error Examples

#### Validation Error (400)
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Must be a valid email address"
    },
    {
      "field": "password",
      "message": "Password must be at least 8 characters long"
    }
  ]
}
```

#### Unauthorized (401)
```json
{
  "success": false,
  "message": "Authentication required",
  "errors": [
    {
      "field": "token",
      "message": "No token provided"
    }
  ]
}
```

#### Not Found (404)
```json
{
  "success": false,
  "message": "Article with id abc-123 not found"
}
```

---

## 🔐 Authentication

### How Authentication Works

1. User signs up or logs in
2. Server returns a JWT token
3. Client stores the token (localStorage, AsyncStorage, etc.)
4. Client includes token in `Authorization` header for protected routes

### Token Format
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Token Properties
- **Expiration:** 7 days
- **Payload:** `{ id, username, email, isAdmin }`
- **Storage:** Store securely on client side

### Example: Setting Headers
```javascript
// JavaScript/React Native example
const headers = {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${userToken}`
};

fetch('http://localhost:3000/api/articles', {
  method: 'GET',
  headers: headers
});
```

---

## 🚦 Rate Limiting

| Endpoint Type | Limit |
|--------------|-------|
| General API | 100 requests per 15 minutes per IP |
| Auth Endpoints (login/signup) | 5 requests per 15 minutes per IP |
| Create Endpoints (POST) | 10 requests per hour per IP |

**When rate limit is exceeded:**
- Status: `429 Too Many Requests`
- Response includes `Retry-After` header

---

## 🔌 Endpoints

---

## 1. Authentication Endpoints

### 1.1 Sign Up (Register New User)

Create a new user account.

**Endpoint:** `POST /api/auth/signup`  
**Authentication:** None required  
**Rate Limit:** 5 requests per 15 minutes

#### Request Body
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

#### Field Requirements
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `username` | string | ✅ Yes | 3-50 chars, alphanumeric + underscore only |
| `email` | string | ✅ Yes | Valid email format |
| `password` | string | ✅ Yes | Min 8 chars, must contain: 1 uppercase, 1 lowercase, 1 number |

#### Success Response (201 Created)
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "username": "johndoe",
      "email": "john@example.com",
      "isAdmin": false,
      "createdAt": "2025-11-08T10:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Error Responses
**Email Already Exists (409)**
```json
{
  "success": false,
  "message": "Email already registered"
}
```

**Username Taken (409)**
```json
{
  "success": false,
  "message": "Username already taken"
}
```

---

### 1.2 Login

Authenticate existing user.

**Endpoint:** `POST /api/auth/login`  
**Authentication:** None required  
**Rate Limit:** 5 requests per 15 minutes

#### Request Body
```json
{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

#### Field Requirements
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `email` | string | ✅ Yes | Valid email format |
| `password` | string | ✅ Yes | User's password |

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "username": "johndoe",
      "email": "john@example.com",
      "isAdmin": false,
      "createdAt": "2025-11-08T10:30:00.000Z",
      "lastLoginAt": "2025-11-08T14:45:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Error Response
**Invalid Credentials (401)**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

---

### 1.3 Get My Profile

Get current authenticated user's account info.

**Endpoint:** `GET /api/auth/profile`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "johndoe",
    "email": "john@example.com",
    "isAdmin": false,
    "createdAt": "2025-11-08T10:30:00.000Z",
    "lastLoginAt": "2025-11-08T14:45:00.000Z",
    "profile": {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "displayName": "John Doe",
      "bio": "Love reading about science and history!",
      "interests": ["Science", "History", "Technology"],
      "updatedAt": "2025-11-08T12:00:00.000Z"
    }
  }
}
```

**Note:** If user hasn't created a profile yet, `profile` will be `null`.

---

## 2. User Profile Endpoints

### 2.1 Get My Profile

Get current user's profile details.

**Endpoint:** `GET /api/profiles/me`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "displayName": "John Doe",
    "bio": "Love reading about science and history!",
    "interests": ["Science", "History", "Technology"],
    "updatedAt": "2025-11-08T12:00:00.000Z",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "username": "johndoe",
      "email": "john@example.com",
      "createdAt": "2025-11-08T10:30:00.000Z"
    }
  }
}
```

#### Error Response
**Profile Not Found (404)**
```json
{
  "success": false,
  "message": "Profile not found"
}
```

---

### 2.2 Create My Profile

Create a profile for the current user.

**Endpoint:** `POST /api/profiles/me`  
**Authentication:** ✅ Required  
**Rate Limit:** 10 requests per hour

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "displayName": "John Doe",
  "bio": "Love reading about science and history!",
  "interests": ["Science", "History", "Technology"]
}
```

#### Field Requirements
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `displayName` | string | ❌ Optional | 1-100 characters |
| `bio` | string | ❌ Optional | Max 500 characters |
| `interests` | string[] | ❌ Optional | Array of strings, each 1-50 chars |

**Note:** All fields are optional. You can create an empty profile.

#### Success Response (201 Created)
```json
{
  "success": true,
  "message": "Profile created successfully",
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "displayName": "John Doe",
    "bio": "Love reading about science and history!",
    "interests": ["Science", "History", "Technology"],
    "updatedAt": "2025-11-08T12:00:00.000Z"
  }
}
```

#### Error Response
**Profile Already Exists (409)**
```json
{
  "success": false,
  "message": "Profile already exists for this user"
}
```

---

### 2.3 Update My Profile

Update current user's profile.

**Endpoint:** `PUT /api/profiles/me`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "displayName": "John Updated",
  "bio": "New bio text",
  "interests": ["Science", "Art"]
}
```

**Note:** All fields are optional. Only include fields you want to update.

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "displayName": "John Updated",
    "bio": "New bio text",
    "interests": ["Science", "Art"],
    "updatedAt": "2025-11-08T15:30:00.000Z"
  }
}
```

---

### 2.4 Delete My Profile

Delete current user's profile.

**Endpoint:** `DELETE /api/profiles/me`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### Success Response (204 No Content)
No response body. Status code indicates success.

---

## 3. Article Endpoints

### 3.1 List Articles

Get paginated list of articles with filtering and sorting.

**Endpoint:** `GET /api/articles`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### Query Parameters
| Parameter | Type | Required | Default | Options |
|-----------|------|----------|---------|---------|
| `page` | integer | ❌ Optional | `1` | Min: 1 |
| `limit` | integer | ❌ Optional | `20` | 1-100 |
| `sortBy` | string | ❌ Optional | `createdAt` | `createdAt`, `title`, `publishedDate`, `viewCount`, `likeCount` |
| `sortOrder` | string | ❌ Optional | `desc` | `asc`, `desc` |

#### Example Request
```
GET /api/articles?page=1&limit=10&sortBy=likeCount&sortOrder=desc
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Articles retrieved successfully",
  "data": {
    "articles": [
      {
        "id": "770e8400-e29b-41d4-a716-446655440003",
        "title": "Quantum Computing",
        "wikipediaUrl": "https://en.wikipedia.org/wiki/Quantum_computing",
        "aiSummary": "Quantum computing harnesses quantum mechanics to solve problems...",
        "audioUrl": "https://example.com/audio/quantum.mp3",
        "tags": ["Technology", "Physics", "Computing"],
        "publishedDate": "2025-01-15T00:00:00.000Z",
        "createdAt": "2025-11-01T10:00:00.000Z",
        "isActive": true,
        "isProcessed": true,
        "viewCount": 1523,
        "likeCount": 342,
        "saveCount": 128,
        "categoryId": "880e8400-e29b-41d4-a716-446655440005",
        "category": {
          "id": "880e8400-e29b-41d4-a716-446655440005",
          "name": "Technology",
          "color": "#4CAF50"
        }
      },
      {
        "id": "770e8400-e29b-41d4-a716-446655440004",
        "title": "Ancient Rome",
        "wikipediaUrl": "https://en.wikipedia.org/wiki/Ancient_Rome",
        "aiSummary": "Ancient Rome was a civilization that began on the Italian Peninsula...",
        "audioUrl": null,
        "tags": ["History", "Ancient Civilizations"],
        "publishedDate": "2024-12-10T00:00:00.000Z",
        "createdAt": "2025-11-02T14:30:00.000Z",
        "isActive": true,
        "isProcessed": true,
        "viewCount": 2103,
        "likeCount": 567,
        "saveCount": 234,
        "categoryId": "880e8400-e29b-41d4-a716-446655440006",
        "category": {
          "id": "880e8400-e29b-41d4-a716-446655440006",
          "name": "History",
          "color": "#FF9800"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 156,
      "totalPages": 16
    }
  }
}
```

---

### 3.2 Get Article by ID

Get details of a specific article.

**Endpoint:** `GET /api/articles/:id`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | ✅ Yes | Article ID |

#### Example Request
```
GET /api/articles/770e8400-e29b-41d4-a716-446655440003
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Article retrieved successfully",
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440003",
    "title": "Quantum Computing",
    "wikipediaUrl": "https://en.wikipedia.org/wiki/Quantum_computing",
    "aiSummary": "Quantum computing harnesses quantum mechanics to solve problems faster than classical computers. Key concepts include qubits, superposition, and entanglement...",
    "audioUrl": "https://example.com/audio/quantum.mp3",
    "tags": ["Technology", "Physics", "Computing"],
    "publishedDate": "2025-01-15T00:00:00.000Z",
    "createdAt": "2025-11-01T10:00:00.000Z",
    "isActive": true,
    "isProcessed": true,
    "viewCount": 1523,
    "likeCount": 342,
    "saveCount": 128,
    "categoryId": "880e8400-e29b-41d4-a716-446655440005",
    "category": {
      "id": "880e8400-e29b-41d4-a716-446655440005",
      "name": "Technology",
      "description": "Articles about technology and innovation",
      "color": "#4CAF50",
      "articleCount": 45,
      "createdAt": "2025-10-15T09:00:00.000Z",
      "updatedAt": "2025-11-05T12:00:00.000Z"
    }
  }
}
```

#### Error Response
**Article Not Found (404)**
```json
{
  "success": false,
  "message": "Article with id 770e8400-e29b-41d4-a716-446655440003 not found"
}
```

---

### 3.3 Increment View Count

Record that user viewed an article (increments view counter).

**Endpoint:** `POST /api/articles/:id/view`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | ✅ Yes | Article ID |

#### Example Request
```
POST /api/articles/770e8400-e29b-41d4-a716-446655440003/view
```

**Note:** No request body needed.

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "View count incremented successfully",
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440003",
    "title": "Quantum Computing",
    "viewCount": 1524,
    "likeCount": 342,
    "saveCount": 128
    // ... other article fields
  }
}
```

**Usage Tip:** Call this endpoint when:
- User opens/views an article
- Article appears in viewport for X seconds
- Based on your UX requirements

---

## 4. Interaction Endpoints

### 4.1 Create Interaction

Record user interaction (like, view, or save).

**Endpoint:** `POST /api/interactions`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "articleId": "770e8400-e29b-41d4-a716-446655440003",
  "interactionType": "LIKE"
}
```

#### Field Requirements
| Field | Type | Required | Options |
|-------|------|----------|---------|
| `articleId` | UUID | ✅ Yes | Valid article ID |
| `interactionType` | string | ✅ Yes | `LIKE`, `VIEW`, `SAVE` |

#### Interaction Types Explained
- **LIKE**: User likes the article (one per user per article)
- **VIEW**: User viewed the article (can be created multiple times)
- **SAVE**: User saves/bookmarks article (one per user per article)

#### Success Response (201 Created)
```json
{
  "success": true,
  "message": "Interaction created successfully",
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440007",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "articleId": "770e8400-e29b-41d4-a716-446655440003",
    "interactionType": "LIKE",
    "createdAt": "2025-11-08T16:20:00.000Z"
  }
}
```

#### Error Response
**Already Liked/Saved (409)**
```json
{
  "success": false,
  "message": "Interaction already exists"
}
```

**Note:** This happens when trying to LIKE or SAVE an article you've already liked/saved. VIEW interactions can be created multiple times.

---

### 4.2 Get My Interactions

Get all interactions for the current user (liked, saved, viewed articles).

**Endpoint:** `GET /api/interactions/me`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### Query Parameters
| Parameter | Type | Required | Options | Description |
|-----------|------|----------|---------|-------------|
| `type` | string | ❌ Optional | `LIKE`, `VIEW`, `SAVE` | Filter by interaction type |

#### Example Requests
```
GET /api/interactions/me
GET /api/interactions/me?type=LIKE
GET /api/interactions/me?type=SAVE
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Interactions retrieved successfully",
  "data": [
    {
      "id": "990e8400-e29b-41d4-a716-446655440007",
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "articleId": "770e8400-e29b-41d4-a716-446655440003",
      "interactionType": "LIKE",
      "createdAt": "2025-11-08T16:20:00.000Z",
      "article": {
        "id": "770e8400-e29b-41d4-a716-446655440003",
        "title": "Quantum Computing",
        "wikipediaUrl": "https://en.wikipedia.org/wiki/Quantum_computing",
        "aiSummary": "Quantum computing harnesses...",
        "audioUrl": "https://example.com/audio/quantum.mp3",
        "tags": ["Technology", "Physics"],
        "viewCount": 1524,
        "likeCount": 343,
        "saveCount": 128,
        "category": {
          "id": "880e8400-e29b-41d4-a716-446655440005",
          "name": "Technology",
          "color": "#4CAF50"
        }
      }
    },
    {
      "id": "990e8400-e29b-41d4-a716-446655440008",
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "articleId": "770e8400-e29b-41d4-a716-446655440004",
      "interactionType": "SAVE",
      "createdAt": "2025-11-08T14:10:00.000Z",
      "article": {
        "id": "770e8400-e29b-41d4-a716-446655440004",
        "title": "Ancient Rome",
        "wikipediaUrl": "https://en.wikipedia.org/wiki/Ancient_Rome",
        "aiSummary": "Ancient Rome was a civilization...",
        "audioUrl": null,
        "tags": ["History"],
        "viewCount": 2103,
        "likeCount": 567,
        "saveCount": 235,
        "category": {
          "id": "880e8400-e29b-41d4-a716-446655440006",
          "name": "History",
          "color": "#FF9800"
        }
      }
    }
  ]
}
```

**Use Cases:**
- Get liked articles: `?type=LIKE`
- Get saved/bookmarked articles: `?type=SAVE`
- Get view history: `?type=VIEW`
- Get all interactions: no query parameter

---

### 4.3 Check Interaction

Check if user has a specific interaction with an article.

**Endpoint:** `GET /api/interactions/check/:articleId`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `articleId` | UUID | ✅ Yes | Article ID to check |

#### Query Parameters
| Parameter | Type | Required | Options |
|-----------|------|----------|---------|
| `type` | string | ✅ Yes | `LIKE`, `VIEW`, `SAVE` |

#### Example Requests
```
GET /api/interactions/check/770e8400-e29b-41d4-a716-446655440003?type=LIKE
GET /api/interactions/check/770e8400-e29b-41d4-a716-446655440003?type=SAVE
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Interaction check completed",
  "data": {
    "hasInteraction": true
  }
}
```

**Use Cases:**
- Show filled/unfilled heart icon (check if user liked)
- Show bookmark icon state (check if user saved)
- Display appropriate UI state

---

### 4.4 Delete Interaction

Remove an interaction (unlike or unsave an article).

**Endpoint:** `DELETE /api/interactions`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "articleId": "770e8400-e29b-41d4-a716-446655440003",
  "interactionType": "LIKE"
}
```

#### Field Requirements
| Field | Type | Required | Options |
|-------|------|----------|---------|
| `articleId` | UUID | ✅ Yes | Valid article ID |
| `interactionType` | string | ✅ Yes | `LIKE`, `SAVE` (VIEW cannot be deleted) |

**Important:** You can only delete LIKE and SAVE interactions. VIEW interactions are permanent records.

#### Success Response (204 No Content)
No response body. Status code indicates success.

#### Error Response
**Trying to Delete VIEW (400)**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "interactionType",
      "message": "Interaction type must be one of: LIKE, SAVE (VIEW cannot be deleted)"
    }
  ]
}
```

**Interaction Not Found (404)**
```json
{
  "success": false,
  "message": "Interaction not found"
}
```

---

## 5. Feed Endpoints

### 5.1 Get My Feed

Get current user's personalized article feed.

**Endpoint:** `GET /api/feeds/me`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Feed retrieved successfully",
  "data": {
    "id": "aa0e8400-e29b-41d4-a716-446655440009",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "articleIds": [
      "770e8400-e29b-41d4-a716-446655440003",
      "770e8400-e29b-41d4-a716-446655440004",
      "770e8400-e29b-41d4-a716-446655440010",
      "770e8400-e29b-41d4-a716-446655440011"
    ],
    "currentPosition": 2,
    "updatedAt": "2025-11-08T10:00:00.000Z"
  }
}
```

#### Response Fields Explained
- **articleIds**: Array of article IDs in feed order
- **currentPosition**: Index of where user is in the feed (0-based)
- **updatedAt**: Last time feed was updated/regenerated

**Important:** If user doesn't have a feed yet, it will be automatically created empty on first access.

---

### 5.2 Create My Feed

Manually create a feed (usually auto-created on first access).

**Endpoint:** `POST /api/feeds/me`  
**Authentication:** ✅ Required  
**Rate Limit:** 10 requests per hour

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "articleIds": [
    "770e8400-e29b-41d4-a716-446655440003",
    "770e8400-e29b-41d4-a716-446655440004"
  ]
}
```

#### Field Requirements
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `articleIds` | UUID[] | ❌ Optional | Array of valid article UUIDs |

**Note:** Can be an empty array or omitted entirely.

#### Success Response (201 Created)
```json
{
  "success": true,
  "message": "Feed created successfully",
  "data": {
    "id": "aa0e8400-e29b-41d4-a716-446655440009",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "articleIds": [
      "770e8400-e29b-41d4-a716-446655440003",
      "770e8400-e29b-41d4-a716-446655440004"
    ],
    "currentPosition": 0,
    "updatedAt": "2025-11-08T16:30:00.000Z"
  }
}
```

#### Error Response
**Feed Already Exists (409)**
```json
{
  "success": false,
  "message": "Feed already exists for this user"
}
```

---

### 5.3 Update My Feed

Update feed articles or position.

**Endpoint:** `PUT /api/feeds/me`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "articleIds": [
    "770e8400-e29b-41d4-a716-446655440020",
    "770e8400-e29b-41d4-a716-446655440021"
  ],
  "currentPosition": 5
}
```

#### Field Requirements
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `articleIds` | UUID[] | ❌ Optional | Array of valid article UUIDs |
| `currentPosition` | integer | ❌ Optional | Non-negative integer (0 or greater) |

**Note:** All fields optional. Include only what you want to update.

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Feed updated successfully",
  "data": {
    "id": "aa0e8400-e29b-41d4-a716-446655440009",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "articleIds": [
      "770e8400-e29b-41d4-a716-446655440020",
      "770e8400-e29b-41d4-a716-446655440021"
    ],
    "currentPosition": 5,
    "updatedAt": "2025-11-08T17:00:00.000Z"
  }
}
```

---

### 5.4 Update Feed Position Only

Update just the scroll position in feed (faster than full update).

**Endpoint:** `PUT /api/feeds/me/position`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "position": 8
}
```

#### Field Requirements
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `position` | integer | ✅ Yes | Non-negative integer (0 or greater) |

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Feed position updated successfully",
  "data": {
    "id": "aa0e8400-e29b-41d4-a716-446655440009",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "articleIds": [
      "770e8400-e29b-41d4-a716-446655440003",
      "770e8400-e29b-41d4-a716-446655440004"
    ],
    "currentPosition": 8,
    "updatedAt": "2025-11-08T17:05:00.000Z"
  }
}
```

**Use Case:** Track user's progress through feed, resume where they left off.

---

### 5.5 Regenerate Feed

Completely regenerate feed with new articles (resets position to 0).

**Endpoint:** `POST /api/feeds/me/regenerate`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
Content-Type: application/json
```

#### Request Body
```json
{
  "articleIds": [
    "770e8400-e29b-41d4-a716-446655440030",
    "770e8400-e29b-41d4-a716-446655440031",
    "770e8400-e29b-41d4-a716-446655440032"
  ]
}
```

#### Field Requirements
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `articleIds` | UUID[] | ✅ Yes | Array of valid article UUIDs (cannot be empty) |

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Feed regenerated successfully",
  "data": {
    "id": "aa0e8400-e29b-41d4-a716-446655440009",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "articleIds": [
      "770e8400-e29b-41d4-a716-446655440030",
      "770e8400-e29b-41d4-a716-446655440031",
      "770e8400-e29b-41d4-a716-446655440032"
    ],
    "currentPosition": 0,
    "updatedAt": "2025-11-08T17:10:00.000Z"
  }
}
```

**Use Cases:**
- User refreshes feed to get new content
- Recommendation algorithm provides new article IDs
- User requests personalized feed refresh

---

### 5.6 Delete My Feed

Delete current user's feed.

**Endpoint:** `DELETE /api/feeds/me`  
**Authentication:** ✅ Required  
**Rate Limit:** General (100/15min)

#### Request Headers
```
Authorization: Bearer <your-token>
```

#### Success Response (204 No Content)
No response body. Status code indicates success.

**Note:** Feed will be auto-recreated (empty) on next access to `GET /api/feeds/me`.

---

## 6. System Endpoints

### 6.1 Health Check

Check if API server is running.

**Endpoint:** `GET /health`  
**Authentication:** None required  
**Rate Limit:** None

#### Success Response (200 OK)
```json
{
  "status": "ok",
  "timestamp": "2025-11-08T17:15:00.000Z"
}
```

**Use Case:** 
- Monitor server status
- Check connectivity before making requests
- Health monitoring/diagnostics

---

## 📱 Implementation Examples

### React Native / JavaScript Example

#### 1. Login Flow
```javascript
const API_BASE_URL = 'http://localhost:3000';

async function login(email, password) {
  try {
    const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password }),
    });

    const result = await response.json();

    if (!result.success) {
      throw new Error(result.message);
    }

    // Store token for future requests
    const { token, user } = result.data;
    await AsyncStorage.setItem('authToken', token);
    await AsyncStorage.setItem('user', JSON.stringify(user));

    return result.data;
  } catch (error) {
    console.error('Login error:', error);
    throw error;
  }
}
```

#### 2. Fetch Articles with Token
```javascript
async function getArticles(page = 1, limit = 20) {
  try {
    const token = await AsyncStorage.getItem('authToken');

    const response = await fetch(
      `${API_BASE_URL}/api/articles?page=${page}&limit=${limit}&sortBy=likeCount&sortOrder=desc`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      }
    );

    const result = await response.json();

    if (!result.success) {
      throw new Error(result.message);
    }

    return result.data; // { articles, pagination }
  } catch (error) {
    console.error('Fetch articles error:', error);
    throw error;
  }
}
```

#### 3. Like an Article
```javascript
async function likeArticle(articleId) {
  try {
    const token = await AsyncStorage.getItem('authToken');

    const response = await fetch(`${API_BASE_URL}/api/interactions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        articleId: articleId,
        interactionType: 'LIKE',
      }),
    });

    const result = await response.json();

    if (!result.success) {
      // If already liked, result.success will be false
      if (response.status === 409) {
        console.log('Already liked this article');
      }
      throw new Error(result.message);
    }

    return result.data;
  } catch (error) {
    console.error('Like article error:', error);
    throw error;
  }
}
```

#### 4. Unlike an Article
```javascript
async function unlikeArticle(articleId) {
  try {
    const token = await AsyncStorage.getItem('authToken');

    const response = await fetch(`${API_BASE_URL}/api/interactions`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        articleId: articleId,
        interactionType: 'LIKE',
      }),
    });

    // 204 No Content - success with no body
    if (response.status === 204) {
      return true;
    }

    const result = await response.json();
    throw new Error(result.message);
  } catch (error) {
    console.error('Unlike article error:', error);
    throw error;
  }
}
```

#### 5. Update Feed Position
```javascript
async function updateFeedPosition(position) {
  try {
    const token = await AsyncStorage.getItem('authToken');

    const response = await fetch(`${API_BASE_URL}/api/feeds/me/position`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ position }),
    });

    const result = await response.json();

    if (!result.success) {
      throw new Error(result.message);
    }

    return result.data;
  } catch (error) {
    console.error('Update feed position error:', error);
    throw error;
  }
}
```

#### 6. Error Handling Helper
```javascript
async function handleApiError(error, response) {
  if (response) {
    switch (response.status) {
      case 401:
        // Unauthorized - token expired or invalid
        await AsyncStorage.removeItem('authToken');
        // Navigate to login screen
        navigation.navigate('Login');
        break;
      case 429:
        // Rate limited
        alert('Too many requests. Please try again later.');
        break;
      case 404:
        alert('Resource not found');
        break;
      case 500:
        alert('Server error. Please try again later.');
        break;
      default:
        alert(error.message || 'An error occurred');
    }
  }
}
```

---

## 🎯 Common User Flows

### Flow 1: New User Registration & Setup
1. `POST /api/auth/signup` - Create account
2. Store returned token
3. `POST /api/profiles/me` - Create profile
4. `GET /api/feeds/me` - Auto-create empty feed
5. `GET /api/articles` - Start browsing

### Flow 2: Existing User Login
1. `POST /api/auth/login` - Authenticate
2. Store returned token
3. `GET /api/feeds/me` - Get personalized feed
4. Use `articleIds` to fetch article details

### Flow 3: Scrolling & Interacting
1. `GET /api/articles` - Get article list
2. As user scrolls: `POST /api/articles/:id/view` - Track views
3. User likes: `POST /api/interactions` with type `LIKE`
4. User saves: `POST /api/interactions` with type `SAVE`
5. Update position: `PUT /api/feeds/me/position`

### Flow 4: Viewing Saved Articles
1. `GET /api/interactions/me?type=SAVE` - Get saved articles
2. Display list with article details included
3. User can navigate to full article

### Flow 5: Refreshing Feed
1. Get new article IDs from recommendation algorithm (your logic)
2. `POST /api/feeds/me/regenerate` - Update feed with new IDs
3. Feed resets to position 0
4. User starts scrolling from beginning

---

## 🔍 Best Practices

### 1. Token Management
- **Store securely:** Use AsyncStorage/SecureStore
- **Include in all protected requests**
- **Handle expiration:** 401 responses mean token is invalid
- **Refresh on login:** Always update stored token

### 2. Error Handling
- **Always check `success` field** in response
- **Handle specific status codes** (401, 404, 409, etc.)
- **Show user-friendly messages**
- **Log errors for debugging**

### 3. Performance
- **Paginate article lists** - Don't fetch all at once
- **Cache data locally** - Reduce API calls
- **Debounce position updates** - Don't send on every scroll
- **Prefetch next articles** - Smoother scrolling

### 4. User Experience
- **Show loading states** during API calls
- **Handle offline mode** gracefully
- **Retry failed requests** with exponential backoff
- **Optimistic UI updates** (e.g., like button responds immediately)

### 5. Feed Management
- **Track position regularly** - User can resume
- **Regenerate periodically** - Keep content fresh
- **Batch view tracking** - Don't call `/view` for every millisecond
- **Preload articles** - Better performance

---

## 📞 Support

For questions or issues:
- Check error messages in API responses
- Verify authentication token is valid
- Ensure request format matches documentation
- Check rate limits if getting 429 errors

---

**Last Updated:** November 8, 2025  
**API Version:** 1.0  
**Documentation Version:** 1.0
