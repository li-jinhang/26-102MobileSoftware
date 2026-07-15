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
exports.WorkflowController = void 0;
const common_1 = require("@nestjs/common");
const auth_token_1 = require("../../common/auth-token");
const api_response_1 = require("../../common/api-response");
const mock_db_1 = require("../../data/mock-db");
let WorkflowController = class WorkflowController {
    getTemplates() {
        return (0, api_response_1.ok)((0, mock_db_1.getWorkflowTemplates)());
    }
    getMyInstances(authorization) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getMyWorkflowInstances)(token));
    }
    getTodoInstances(authorization) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getTodoWorkflowInstances)(token));
    }
    getInstance(id) {
        return (0, api_response_1.ok)((0, mock_db_1.getWorkflowInstanceById)(id));
    }
    create(authorization, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.createWorkflow)(token, body), '提交流程成功');
    }
    approve(authorization, id, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.approveWorkflow)(token, id, body.comment), '审批成功');
    }
    reject(authorization, id, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.rejectWorkflow)(token, id, body.comment), '驳回成功');
    }
    securityConfirm(authorization, id, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.securityConfirmWorkflow)(token, id, body.comment), '确认成功');
    }
};
exports.WorkflowController = WorkflowController;
__decorate([
    (0, common_1.Get)('templates'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "getTemplates", null);
__decorate([
    (0, common_1.Get)('instances/my'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "getMyInstances", null);
__decorate([
    (0, common_1.Get)('instances/todo'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "getTodoInstances", null);
__decorate([
    (0, common_1.Get)('instances/:id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "getInstance", null);
__decorate([
    (0, common_1.Post)('instances'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('instances/:id/approve'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "approve", null);
__decorate([
    (0, common_1.Post)('instances/:id/reject'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "reject", null);
__decorate([
    (0, common_1.Post)('instances/:id/security-confirm'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], WorkflowController.prototype, "securityConfirm", null);
exports.WorkflowController = WorkflowController = __decorate([
    (0, common_1.Controller)('workflow')
], WorkflowController);
//# sourceMappingURL=workflow.controller.js.map