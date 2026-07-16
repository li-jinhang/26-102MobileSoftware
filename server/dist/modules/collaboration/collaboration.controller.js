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
exports.CollaborationController = void 0;
const common_1 = require("@nestjs/common");
const auth_token_1 = require("../../common/auth-token");
const api_response_1 = require("../../common/api-response");
const mock_db_1 = require("../../data/mock-db");
let CollaborationController = class CollaborationController {
    getMessages(authorization, threadId = '') {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getCollaborationMessages)(token, threadId));
    }
    sendMessage(authorization, threadId, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.sendCollaborationMessage)(token, threadId, body), '消息已发送');
    }
};
exports.CollaborationController = CollaborationController;
__decorate([
    (0, common_1.Get)('messages'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Query)('threadId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], CollaborationController.prototype, "getMessages", null);
__decorate([
    (0, common_1.Post)('threads/:threadId/messages'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Param)('threadId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], CollaborationController.prototype, "sendMessage", null);
exports.CollaborationController = CollaborationController = __decorate([
    (0, common_1.Controller)('collaboration')
], CollaborationController);
//# sourceMappingURL=collaboration.controller.js.map