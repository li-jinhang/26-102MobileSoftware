type AssistantIntent = 'knowledge_query' | 'leave' | 'reimbursement' | 'purchase' | 'permission' | 'mail' | 'unknown';
type AssistantActionType = 'none' | 'mail' | 'workflow' | 'knowledge';
interface AssistantAnalyzeInput {
    text: string;
    imageBase64: string;
    imageMimeType: string;
}
interface AssistantMailDraft {
    receiverIds: string[];
    receiverNames: string[];
    subject: string;
    content: string;
}
interface AssistantAction {
    type: AssistantActionType;
    label: string;
    mailDraft: AssistantMailDraft | null;
}
export interface AssistantAnalyzeReply {
    answer: string;
    recognizedText: string;
    intent: AssistantIntent;
    relatedKnowledgeIds: string[];
    recommendedWorkflowId: string;
    confidence: number;
    formDraft: {
        title: string;
        extra: string;
        date: string;
        amount: string;
        reason: string;
        attachment: string;
    };
    missingFields: string[];
    action: AssistantAction;
}
export declare class AssistantService {
    analyze(token: string, input: AssistantAnalyzeInput): Promise<AssistantAnalyzeReply>;
    private fallbackDecision;
    private resolveDecision;
    private buildMailDraft;
    private buildWorkflowOrKnowledgeReply;
    private callLlm;
}
export {};
