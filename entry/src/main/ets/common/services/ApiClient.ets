import http from '@ohos.net.http';
import { getAccessToken } from '../../app/repositories/BackendSession';
import { MOBILE_SOFTWARE_BACKEND_BASE_URL } from './ApiConfig';

interface ApiEnvelope<T> {
  code: number;
  message: string;
  data: T;
}

export interface ApiQueryParam {
  key: string;
  value: string;
}

interface ApiHeaders {
  'Content-Type': string;
  Authorization?: string;
}

interface ApiRequestOptions {
  body?: string;
  queryParams?: ApiQueryParam[];
  withAuth?: boolean;
}

interface ApiHttpRequestOptions {
  method: http.RequestMethod;
  header: ApiHeaders;
  connectTimeout: number;
  readTimeout: number;
  expectDataType: http.HttpDataType;
  extraData: string;
}

function buildUrl(path: string, queryParams?: ApiQueryParam[]): string {
  const normalizedPath: string = path.startsWith('/') ? path : `/${path}`;
  const baseUrl: string = `${MOBILE_SOFTWARE_BACKEND_BASE_URL}${normalizedPath}`;
  if (queryParams === undefined || queryParams.length === 0) {
    return baseUrl;
  }

  const queryParts: string[] = [];
  queryParams.forEach((item: ApiQueryParam) => {
    queryParts.push(`${encodeURIComponent(item.key)}=${encodeURIComponent(item.value)}`);
  });
  return `${baseUrl}?${queryParts.join('&')}`;
}

function buildHeaders(withAuth: boolean): ApiHeaders {
  const headers: ApiHeaders = {
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
  options?: ApiRequestOptions
): Promise<T> {
  const client = http.createHttp();
  try {
    const requestOptions: ApiHttpRequestOptions = {
      method,
      header: buildHeaders(options?.withAuth !== false),
      connectTimeout: 15000,
      readTimeout: 15000,
      expectDataType: http.HttpDataType.STRING,
      extraData: options?.body === undefined ? '' : options.body
    };
    const response = await client.request(buildUrl(path, options?.queryParams), requestOptions);

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
  queryParams?: ApiQueryParam[],
  withAuth: boolean = true
): Promise<T> {
  const options: ApiRequestOptions = { queryParams, withAuth };
  return requestJson<T>(http.RequestMethod.GET, path, options);
}

export async function apiPost<T>(
  path: string,
  body?: string,
  withAuth: boolean = true
): Promise<T> {
  const options: ApiRequestOptions = { body, withAuth };
  return requestJson<T>(http.RequestMethod.POST, path, options);
}

export async function apiDelete<T>(path: string, withAuth: boolean = true): Promise<T> {
  const options: ApiRequestOptions = { withAuth };
  return requestJson<T>(http.RequestMethod.DELETE, path, options);
}
