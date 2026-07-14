let accessToken: string = '';

export function setAccessToken(token: string): void {
  accessToken = token;
}

export function getAccessToken(): string {
  return accessToken;
}

export function clearAccessToken(): void {
  accessToken = '';
}
