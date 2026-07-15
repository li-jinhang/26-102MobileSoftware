export interface ApiEnvelope<T> {
    code: number;
    message: string;
    data: T;
}
export declare function ok<T>(data: T, message?: string): ApiEnvelope<T>;
