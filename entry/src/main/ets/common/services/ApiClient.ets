import http from '@ohos.net.http';
import { getAccessToken } from '../../app/repositories/BackendSession';
import { MOBILE_SOFTWARE_BACKEND_BASE_URL } from './ApiConfig';

interface ApiEnvelope<T> {
  code: number;
  message: string;
  data: T;
}

function buildUrl(path: string, query?: Record<string, string | number | boolean | undefined>): string {
  const normalizedPath: string = path.startsWith('/') ? path : `/${path}`;
  const baseUrl: string = `${MOBILE_SOFTWARE_BACKEND_BASE_URL}${normalizedPath}`;
  if (query === undefined) {
    return baseUrl;
  }

  const queryParts: string[] = [];
  Object.keys(query).forEach((key: string) => {
    const value: string | number | boolean | undefined = query[key];
    if (value !== undefined) {
      queryParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
    }
  });
  if (queryParts.length === 0) {
    return baseUrl;
  }
  return `${baseUrl}?${queryParts.join('&')}`;
}

function buildHeaders(withAuth: boolean): Record<string, string> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json'
  };
  if (withAuth) {
    const token: string = getAccessToken();
    if (token.length > 0) {
      headers.Authorization = `Bearer ${token}`;
    }
  }
  return headers;
}

async function requestJson<T>(
  method: http.RequestMethod,
  path: string,
  options?: {
    body?: Record<string, Object | string | number | boolean | undefined> | string;
    query?: Record<string, string | number | boolean | undefined>;
    withAuth?: boolean;
  }
): Promise<T> {
  const client = http.createHttp();
  try {
    const response = await client.request(buildUrl(path, options?.query), {
      method,
      header: buildHeaders(options?.withAuth !== false),
      connectTimeout: 15000,
      readTimeout: 15000,
      expectDataType: http.HttpDataType.STRING,
      extraData: options?.body === undefined
        ? ''
        : typeof options.body === 'string'
          ? options.body
          : JSON.stringify(options.body)
    });

    const payload: ApiEnvelope<T> = JSON.parse(String(response.result));
    if (response.responseCode < 200 || response.responseCode >= 300 || payload.code !== 0) {
      throw new Error(payload.message || '请求失败');
    }
    return payload.data;
  } finally {
    client.destroy();
  }
}

export async function apiGet<T>(
  path: string,
  query?: Record<string, string | number | boolean | undefined>,
  withAuth: boolean = true
): Promise<T> {
  return requestJson<T>(http.RequestMethod.GET, path, {
    query,
    withAuth
  });
}

export async function apiPost<T>(
  path: string,
  body?: Record<string, Object | string | number | boolean | undefined>,
  withAuth: boolean = true
): Promise<T> {
  return requestJson<T>(http.RequestMethod.POST, path, {
    body,
    withAuth
  });
}

export async function apiDelete<T>(path: string, withAuth: boolean = true): Promise<T> {
  return requestJson<T>(http.RequestMethod.DELETE, path, {
    withAuth
  });
}
