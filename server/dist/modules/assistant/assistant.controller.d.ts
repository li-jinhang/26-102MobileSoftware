import { AssistantService } from './assistant.service';
interface AnalyzeAssistantRequest {
    text?: unknown;
    imageBase64?: unknown;
    imageMimeType?: unknown;
}
export declare class AssistantController {
    private readonly assistantService;
    constructor(assistantService: AssistantService);
    analyze(authorization: string | undefined, body: AnalyzeAssistantRequest): Promise<import("../../common/api-response").ApiEnvelope<import("./assistant.service").AssistantAnalyzeReply>>;
}
export {};
