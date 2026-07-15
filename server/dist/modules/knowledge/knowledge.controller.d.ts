export declare class KnowledgeController {
    getCategories(): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").KnowledgeCategory[]>;
    getArticles(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").KnowledgeArticle[]>;
    favorite(authorization: string | undefined, id: string): import("../../common/api-response").ApiEnvelope<{
        articleId: string;
        favorite: boolean;
    }>;
    unfavorite(authorization: string | undefined, id: string): import("../../common/api-response").ApiEnvelope<{
        articleId: string;
        favorite: boolean;
    }>;
    createCorrection(authorization: string | undefined, id: string, body: {
        content: string;
    }): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").KnowledgeCorrection>;
}
