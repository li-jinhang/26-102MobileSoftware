export declare class CollaborationController {
    getMessages(authorization: string | undefined, threadId?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").CollaborationMessageView[]>;
    sendMessage(authorization: string | undefined, threadId: string, body: {
        receiverIds: string[];
        content: string;
    }): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").CollaborationMessageView>;
}
