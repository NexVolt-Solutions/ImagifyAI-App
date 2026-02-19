# Backend: Google Sign-In API (Step-by-Step)

The Flutter app sends the Google ID token to your backend. The backend must **verify the token** and return **JSON** (not HTML). Right now the server returns the website HTML for `POST /api/v1/auth/google`, which causes the app to show an error.

---

## 1. Expose a real API route (not the website)

**Problem:** Requests to `https://imagifyai.io/api/v1/auth/google` are returning the **website HTML** (200 + `<html>...`). That usually means:

- The `/api/v1` path is not routed to your API server, or
- The API server is not running, and the web server falls back to serving the main site (SPA).

**Fix:**

- Ensure your **API server** (Node, Python, etc.) is running and handles `/api/v1/*`.
- In Nginx/reverse proxy: route `/api/v1` to the API backend, **not** to the static/SPA app.
- Example (Nginx):

  ```nginx
  location /api/ {
      proxy_pass http://your-api-backend;
      proxy_http_version 1.1;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
  }
  ```

- Test: `curl -X POST https://api.imagifyai.io/api/v1/auth/google -H "Content-Type: application/json" -d '{}'` should return **JSON** (e.g. `{"detail":"..."}` or your error format), **not** HTML.

---

## 2. Endpoint and request body

| Item | Value |
|------|--------|
| **Method** | `POST` |
| **URL** | `https://api.imagifyai.io/api/v1/auth/google` |
| **Content-Type** | `application/json` |

**Request body (JSON):**

```json
{
  "id_token": "<Google ID token from the app>",
  "name": "Rehman Khan",
  "picture": "https://lh3.googleusercontent.com/..."
}
```

- **id_token** (required): Google OpenID Connect ID token from the app (JWT).
- **name** (required): User display name from Google.
- **picture** (optional): Profile picture URL from Google.

---

## 3. Verify the Google ID token (backend)

**Never** trust the token without verification. Verify it on the server using Google’s Web Client ID.

**Web Client ID (audience):**  
`687032857486-dtgppeu5qk5jfb7ckocrakqsddh8kd67.apps.googleusercontent.com`

### Option A: Google API (HTTP)

1. Call Google’s tokeninfo endpoint:
   ```
   GET https://oauth2.googleapis.com/tokeninfo?id_token=<ID_TOKEN>
   ```
2. Response (200) is JSON, e.g.:
   ```json
   {
     "aud": "687032857486-dtgppeu5qk5jfb7ckocrakqsddh8kd67.apps.googleusercontent.com",
     "email": "user@gmail.com",
     "email_verified": "true",
     "sub": "102712365465171092086",
     "name": "Rehman Khan",
     "picture": "https://..."
   }
   ```
3. Check:
   - **aud** equals your Web Client ID above.
   - **email_verified** is true if you rely on email.

### Option B: JWT library (recommended)

Verify the JWT locally using Google’s public keys (JWKS):

- **JWKS URL:** `https://www.googleapis.com/oauth2/v3/certs`
- Verify: signature, `aud` = Web Client ID, `iss` = `https://accounts.google.com`, `exp` (expiry).

**Python (PyJWT + requests):**

```python
import jwt
import requests

GOOGLE_WEB_CLIENT_ID = "687032857486-dtgppeu5qk5jfb7ckocrakqsddh8kd67.apps.googleusercontent.com"

def get_google_public_keys():
    r = requests.get("https://www.googleapis.com/oauth2/v3/certs")
    return r.json()

def verify_google_id_token(id_token: str) -> dict:
    keys = get_google_public_keys()
    payload = jwt.decode(
        id_token,
        keys,
        algorithms=["RS256"],
        audience=GOOGLE_WEB_CLIENT_ID,
        issuer="https://accounts.google.com",
    )
    return payload  # contains sub, email, name, picture, etc.
```

**Node (google-auth-library):**

```javascript
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client('687032857486-dtgppeu5qk5jfb7ckocrakqsddh8kd67.apps.googleusercontent.com');

async function verifyGoogleIdToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: '687032857486-dtgppeu5qk5jfb7ckocrakqsddh8kd67.apps.googleusercontent.com',
  });
  return ticket.getPayload(); // { sub, email, name, picture, ... }
}
```

Use **sub** as the stable Google user id; use **email**, **name**, **picture** for your user record.

---

## 4. Create or get user and issue your tokens

After verifying the ID token:

1. **Get payload** (e.g. `sub`, `email`, `name`, `picture`).
2. **Find or create user** in your DB (e.g. by `email` or by Google `sub`).
3. **Issue your own JWT** access token and refresh token (same as your email/password login).
4. Return the same JSON shape as your normal login (see below).

---

## 5. Response format (JSON) – required by the app

The app expects a **JSON** body compatible with `LoginResponse`:

```json
{
  "access_token": "<your JWT access token>",
  "refresh_token": "<your refresh token>",
  "token_type": "Bearer",
  "user_id": "<user id in your system>",
  "status": true,
  "message": "Success"
}
```

**Minimum needed:**

- **access_token** (string): Your JWT that the app sends in `Authorization: Bearer <access_token>`.
- **refresh_token** (string): Used to get a new access token (same as your `/auth/refresh`).
- **user_id** (string): Your internal user id (app uses it for API calls and storage).

Optional but useful: **token_type**, **status**, **message**, **data** (e.g. user object).

**Important:** The response must be **application/json** and the body must be **only JSON**. No HTML, no redirect to the website.

---

## 6. Example flow (summary)

1. App sends `POST /api/v1/auth/google` with `{ "id_token", "name", "picture" }`.
2. Backend receives JSON.
3. Backend verifies `id_token` with Google (tokeninfo or JWT verify with Web Client ID).
4. Backend finds or creates user (e.g. by `email` or `sub`).
5. Backend creates access_token and refresh_token (same as email login).
6. Backend returns **JSON** with `access_token`, `refresh_token`, `user_id`, etc.
7. App stores tokens and user_id and continues as logged in.

---

## 7. Checklist

- [ ] `/api/v1` is routed to the API server (not to the HTML site).
- [ ] `POST /api/v1/auth/google` exists and returns **JSON only**.
- [ ] Request body is parsed as JSON (`id_token`, `name`, `picture`).
- [ ] Google ID token is verified (audience = Web Client ID above).
- [ ] User is created/updated; your own access_token and refresh_token are issued.
- [ ] Response includes `access_token`, `refresh_token`, `user_id` in JSON.
- [ ] `Content-Type: application/json` and no HTML/redirect for this route.

Once this is in place, the app’s Google Sign-In will complete successfully.

---

## 8. Troubleshooting: Backend returns "Invalid Google token" (400)

If the backend responds with `{"msg":"Invalid Google token"}` or similar:

**Cause:** Token verification is failing. The ID token from the app is valid (it has the correct `aud`, `iss`, `exp`). The backend must verify it using the **same Web Client ID** the app uses.

**Fix on the backend:**

1. **Use the Web Client ID for verification** (not the Android client ID):
   ```
   687032857486-dtgppeu5qk5jfb7ckocrakqsddh8kd67.apps.googleusercontent.com
   ```
2. **Tokeninfo (quick check):**  
   `GET https://oauth2.googleapis.com/tokeninfo?id_token=<ID_TOKEN>`  
   – Response `aud` must equal the Web Client ID above. If your backend uses a different audience, change it to this Web Client ID.
3. **JWT verification:** When verifying the JWT (e.g. with `google-auth-library`, PyJWT, or similar), set **audience** (or **aud**) to the Web Client ID above. Do **not** use the Android OAuth client ID for server-side verification of this token.
4. **Request body:** The app sends JSON: `{"id_token": "<jwt>", "name": "...", "picture": "..."}`. Ensure the backend reads `id_token` from the JSON body (not `idToken` or a header) and passes that exact string to the verifier.

After updating the backend to verify with the Web Client ID, Google Sign-In should succeed.
