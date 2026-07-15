export declare class AssistantController {
    ask(body: {
        question: string;
    }): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").AssistantReply>;
}
