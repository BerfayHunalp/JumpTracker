import { Env, AuthContext } from '../types';
import { verifyJwt } from '../services/jwt';
import { error } from '../utils/response';

export async function authenticate(
  request: Request,
  env: Env,
): Promise<AuthContext | Response> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return error('Missing or invalid Authorization header', 401);
  }

  const token = authHeader.slice(7);
  const payload = await verifyJwt(token, env.JWT_SECRET);
  if (!payload) {
    return error('Invalid or expired token', 401);
  }

  return { userId: payload.sub, email: payload.email };
}
