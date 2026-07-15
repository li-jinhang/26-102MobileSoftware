export declare class AttendanceController {
    getToday(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").AttendanceTodaySummary>;
    getMyRecords(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").AttendanceRecord[]>;
    checkIn(authorization: string | undefined, body: {
        location: string;
        note: string;
    }): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").AttendanceTodaySummary>;
    checkOut(authorization: string | undefined, body: {
        location: string;
        note: string;
    }): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").AttendanceTodaySummary>;
}
