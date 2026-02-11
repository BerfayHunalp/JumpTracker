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
      if (path.startsWith('/auth/')) return handleAuth(request, env, path);
      if (path.startsWith('/users/')) return handleUsers(request, env, path);
      if (path.startsWith('/sync/')) return handleSync(request, env, path);
      if (path.startsWith('/friends')) return handleFriends(request, env, path);
      if (path.startsWith('/leaderboard/'))
        return handleLeaderboard(request, env, path);

      return error('Not Found', 404);
    } catch (err) {
      console.error('Unhandled error:', err);
      return error('Internal Server Error', 500);
    }
  },
};
