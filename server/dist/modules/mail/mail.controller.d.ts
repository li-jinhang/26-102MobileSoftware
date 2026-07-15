export declare class MailController {
    getInbox(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").MailMessage[]>;
    getSent(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").MailMessage[]>;
    getMail(authorization: string | undefined, id: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").MailMessage>;
    send(authorization: string | undefined, body: {
        receiverIds: string[];
        subject: string;
        content: string;
        relatedWorkflowId: string;
        relatedKnowledgeId: string;
    }): import("../../common/api-response").ApiEnvelope<{
        id: string;
    }>;
    markRead(authorization: string | undefined, id: string): import("../../common/api-response").ApiEnvelope<{
        id: string;
        read: boolean;
    }>;
    delete(authorization: string | undefined, id: string): import("../../common/api-response").ApiEnvelope<{
        id: string;
    }>;
}
