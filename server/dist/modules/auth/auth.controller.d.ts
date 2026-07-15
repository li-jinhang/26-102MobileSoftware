export declare class AuthController {
    login(body: {
        account: string;
        password: string;
    }): import("../../common/api-response").ApiEnvelope<{
        token: string;
        user: {
            password: string;
            id: string;
            name: string;
            account: string;
            department: string;
            role: import("../../data/mock-db").UserRole;
            roleLabel: string;
            permissions: string[];
            favoriteKnowledgeIds: string[];
            recentKnowledgeIds: string[];
            todoCount: number;
        };
    }>;
    getMe(authorization?: string): import("../../common/api-response").ApiEnvelope<{
        password: string;
        id: string;
        name: string;
        account: string;
        department: string;
        role: import("../../data/mock-db").UserRole;
        roleLabel: string;
        permissions: string[];
        favoriteKnowledgeIds: string[];
        recentKnowledgeIds: string[];
        todoCount: number;
    }>;
    logout(): import("../../common/api-response").ApiEnvelope<null>;
}
