export declare class OrganizationController {
    getMe(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").OrganizationProfile>;
    getDepartments(authorization?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").DepartmentTreeItem[]>;
    getUsers(authorization?: string, scope?: string, departmentId?: string, keyword?: string, activeOnly?: string): import("../../common/api-response").ApiEnvelope<import("../../data/mock-db").DirectoryItem[]>;
}
