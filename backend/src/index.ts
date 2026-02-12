import { Env } from './types';
import { handleOptions } from './utils/response';
import { handleAuth } from './routes/auth';
import { handleUsers } from './routes/users';
import { handleSync } from './routes/sync';
import { handleFriends } from './routes/friends';
import { handleLeaderboard } from './routes/leaderboard';
import { error } from './utils/response';

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<Response> {
    if (request.method === 'OPTIONS') {
      return handleOptions();
    }

    const url = new URL(request.url);
    const path = url.pathname;

    try {
      if (path.startsWith('/auth/')) return await handleAuth(request, env, path);
      if (path.startsWith('/users/')) return await handleUsers(request, env, path);
      if (path.startsWith('/sync/')) return await handleSync(request, env, path);
      if (path.startsWith('/friends')) return await handleFriends(request, env, path);
      if (path.startsWith('/leaderboard/'))
        return await handleLeaderboard(request, env, path);

      return error('Not Found', 404);
    } catch (err: any) {
      console.error('Unhandled error:', err?.message || err, err?.stack);
      return error(err?.message || 'Internal Server Error', 500);
    }
  },
};
