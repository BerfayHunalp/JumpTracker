export interface Env {
  DB: D1Database;
  JWT_SECRET: string;
  GOOGLE_CLIENT_ID: string;
  APPLE_BUNDLE_ID: string;
  INVITE_BASE_URL: string;
}

export interface AuthContext {
  userId: string;
  email: string;
}
