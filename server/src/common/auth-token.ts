export function getBearerToken(authorization?: string): string {
  if (authorization === undefined || authorization.length === 0) {
    throw new Error('未登录或 Token 无效');
  }
  return authorization.replace('Bearer ', '').trim();
}
