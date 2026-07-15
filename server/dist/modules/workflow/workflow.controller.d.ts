export declare class WorkflowController {
    getTemplates(): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").WorkflowTemplate[]>;
    getMyInstances(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").WorkflowInstance[]>;
    getTodoInstances(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").WorkflowInstance[]>;
    getInstance(id: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").WorkflowInstance>;
    create(authorization: string | undefined, body: {
        templateId: string;
        title: string;
        extraInput: string;
        dateInput: string;
        amountInput: number;
        reasonInput: string;
        attachmentInput: string;
    }): import("../../common/api-response").ApiEnvelope<{
        id: string;
    }>;
    approve(authorization: string | undefined, id: string, body: {
        comment: string;
    }): import("../../common/api-response").ApiEnvelope<{
        id: string;
    }>;
    reject(authorization: string | undefined, id: string, body: {
        comment: string;
    }): import("../../common/api-response").ApiEnvelope<{
        id: string;
    }>;
    securityConfirm(authorization: string | undefined, id: string, body: {
        comment: string;
    }): import("../../common/api-response").ApiEnvelope<{
        id: string;
    }>;
}
