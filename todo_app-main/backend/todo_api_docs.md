# Todo App API Documentation

## Authentication

All endpoints except registration and login require authentication via JWT token in the Authorization header.

**Header Format:**
```
Authorization: Bearer <your_jwt_token>
```

---

## Endpoints

### Authentication

#### Register User
Create a new user account.

**Endpoint:** `POST /auth/register`

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:** `201 Created`
```json
{
  "id": "string",
  "username": "string",
  "token": "string"
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input or username already exists
- `422 Unprocessable Entity` - Validation errors

---

#### Login
Authenticate and receive access token.

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:** `200 OK`
```json
{
  "id": "string",
  "username": "string",
  "token": "string"
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid credentials
- `400 Bad Request` - Missing required fields

---

### Todos

#### Get All Todos
Retrieve all todos for the authenticated user.

**Endpoint:** `GET /todos`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `status` (optional): Filter by status (`completed`, `pending`)
- `sort` (optional): Sort order (`createdAt`)
- `order` (optional): `asc` or `desc` (default: `desc`)

**Response:** `200 OK`
```json
{
  "todos": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "completed": false,
      "imageUrl": "string | null",
      "createdAt": "2026-01-26T10:00:00Z"
    }
  ],
  "total": 10
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token

---

#### Get Single Todo
Retrieve a specific todo by ID.

**Endpoint:** `GET /todos/:id`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `200 OK`
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "completed": false,
  "imageUrl": "string | null",
  "createdAt": "2026-01-26T10:00:00Z"
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token
- `404 Not Found` - Todo not found
- `403 Forbidden` - Todo belongs to another user

---

#### Create Todo
Create a new todo item.

**Endpoint:** `POST /todos`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "title": "string",
  "description": "string" // optional
}
```

**Response:** `201 Created`
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "completed": false,
  "imageUrl": null,
  "createdAt": "2026-01-26T10:00:00Z"
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token
- `400 Bad Request` - Missing required fields
- `422 Unprocessable Entity` - Validation errors

---

#### Update Todo
Update an existing todo item.

**Endpoint:** `PUT /todos/:id`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "title": "string", // optional
  "description": "string", // optional
  "completed": boolean // optional
}
```

**Response:** `200 OK`
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "completed": false,
  "imageUrl": "string | null",
  "createdAt": "2026-01-26T10:00:00Z",
  "updatedAt": "2026-01-26T10:00:00Z"
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token
- `404 Not Found` - Todo not found
- `403 Forbidden` - Todo belongs to another user
- `400 Bad Request` - Invalid input

---

#### Delete Todo
Delete a todo item.

**Endpoint:** `DELETE /todos/:id`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `204 No Content`

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token
- `404 Not Found` - Todo not found
- `403 Forbidden` - Todo belongs to another user

---

### Todo Media

#### Upload Image for Todo
Upload an image for a specific todo item. Maximum file size: 5MB. Supported formats: JPEG, PNG, GIF, WEBP.

**Endpoint:** `POST /todos/:id/image`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Request Body (multipart/form-data):**
- `image` (file): The image file to upload

**Response:** `200 OK`
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "completed": false,
  "imageUrl": "https://your-bucket.s3.amazonaws.com/todos/user123/todo456.jpg",
  "createdAt": "2026-01-26T10:00:00Z",
  "updatedAt": "2026-01-26T10:00:00Z"
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token
- `404 Not Found` - Todo not found
- `403 Forbidden` - Todo belongs to another user
- `400 Bad Request` - No file provided or invalid file type
- `413 Payload Too Large` - File exceeds maximum size
- `500 Internal Server Error` - S3 upload failed

**Example cURL:**
```bash
curl -X POST \
  https://api.example.com/todos/123/image \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/image.jpg"
```

---

#### Get Todo Image
Retrieve the image URL for a todo item. If the S3 bucket is private, this endpoint returns a signed URL valid for 1 hour.

**Endpoint:** `GET /todos/:id/image`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `200 OK`
```json
{
  "imageUrl": "https://your-bucket.s3.amazonaws.com/todos/user123/todo456.jpg",
  "expiresAt": "2026-01-26T11:00:00Z" // only if using signed URLs
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token
- `404 Not Found` - Todo not found or todo has no image
- `403 Forbidden` - Todo belongs to another user

---

#### Delete Todo Image
Delete the image associated with a todo item.

**Endpoint:** `DELETE /todos/:id/image`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `200 OK`
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "completed": false,
  "imageUrl": null,
  "createdAt": "2026-01-26T10:00:00Z",
  "updatedAt": "2026-01-26T10:00:00Z"
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid token
- `404 Not Found` - Todo not found or todo has no image
- `403 Forbidden` - Todo belongs to another user
- `500 Internal Server Error` - S3 deletion failed

---

## Error Response Format

All error responses follow this structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {} // optional, additional error information
  }
}
```

## Common Error Codes

- `INVALID_CREDENTIALS` - Username or password is incorrect
- `USERNAME_EXISTS` - Username already taken
- `INVALID_TOKEN` - JWT token is invalid or expired
- `MISSING_TOKEN` - Authorization header missing
- `TODO_NOT_FOUND` - Requested todo does not exist
- `UNAUTHORIZED_ACCESS` - User doesn't have permission
- `VALIDATION_ERROR` - Input validation failed
- `INTERNAL_ERROR` - Server error
- `INVALID_FILE_TYPE` - File type not supported
- `FILE_TOO_LARGE` - File exceeds maximum size limit
- `NO_IMAGE_FOUND` - Todo item has no associated image
- `UPLOAD_FAILED` - Failed to upload file to storage
- `DELETE_FAILED` - Failed to delete file from storage

## Database Schema Changes

The Todo model now includes:

```javascript
{
  id: "string",
  title: "string",
  description: "string",
  completed: "boolean",
  imageUrl: "string | null",      // S3 URL of the image
  imageKey: "string | null",       // S3 object key for deletion
  userId: "string",
  createdAt: "datetime",
  updatedAt: "datetime"
}
```