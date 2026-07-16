"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrganizationController = void 0;
const common_1 = require("@nestjs/common");
const auth_token_1 = require("../../common/auth-token");
const api_response_1 = require("../../common/api-response");
const mock_db_1 = require("../../data/mock-db");
let OrganizationController = class OrganizationController {
    getMe(authorization) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getMyOrganization)(token));
    }
    getDepartments(authorization) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getDepartmentTree)(token));
    }
    getUsers(authorization, scope = 'team', departmentId = '', keyword = '', activeOnly = 'true') {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.searchOrganizationUsers)(token, scope, departmentId, keyword, activeOnly !== 'false'));
    }
};
exports.OrganizationController = OrganizationController;
__decorate([
    (0, common_1.Get)('me'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], OrganizationController.prototype, "getMe", null);
__decorate([
    (0, common_1.Get)('departments/tree'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], OrganizationController.prototype, "getDepartments", null);
__decorate([
    (0, common_1.Get)('users'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Query)('scope')),
    __param(2, (0, common_1.Query)('departmentId')),
    __param(3, (0, common_1.Query)('keyword')),
    __param(4, (0, common_1.Query)('activeOnly')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String]),
    __metadata("design:returntype", void 0)
], OrganizationController.prototype, "getUsers", null);
exports.OrganizationController = OrganizationController = __decorate([
    (0, common_1.Controller)('organization')
], OrganizationController);
//# sourceMappingURL=organization.controller.js.map