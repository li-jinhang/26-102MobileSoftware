export declare class NotificationsController {
    getList(authorization?: string, unreadOnly?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").NotificationItem[]>;
    markRead(id: string): import("../../common/api-response").ApiEnvelope<{
        id: string;
        read: boolean;
    }>;
}
