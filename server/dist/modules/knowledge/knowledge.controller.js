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
exports.KnowledgeController = void 0;
const common_1 = require("@nestjs/common");
const auth_token_1 = require("../../common/auth-token");
const api_response_1 = require("../../common/api-response");
const mock_db_1 = require("../../data/mock-db");
let KnowledgeController = class KnowledgeController {
    getCategories() {
        return (0, api_response_1.ok)((0, mock_db_1.getCategories)());
    }
    getArticles(authorization) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getArticles)(token));
    }
    favorite(authorization, id) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.favoriteArticle)(token, id), '收藏成功');
    }
    unfavorite(authorization, id) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.unfavoriteArticle)(token, id), '取消收藏成功');
    }
    createCorrection(authorization, id, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.createCorrection)(token, id, body.content), '提交成功');
    }
};
exports.KnowledgeController = KnowledgeController;
__decorate([
    (0, common_1.Get)('categories'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], KnowledgeController.prototype, "getCategories", null);
__decorate([
    (0, common_1.Get)('articles'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], KnowledgeController.prototype, "getArticles", null);
__decorate([
    (0, common_1.Post)('articles/:id/favorite'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], KnowledgeController.prototype, "favorite", null);
__decorate([
    (0, common_1.Delete)('articles/:id/favorite'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], KnowledgeController.prototype, "unfavorite", null);
__decorate([
    (0, common_1.Post)('articles/:id/corrections'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], KnowledgeController.prototype, "createCorrection", null);
exports.KnowledgeController = KnowledgeController = __decorate([
    (0, common_1.Controller)('knowledge')
], KnowledgeController);
//# sourceMappingURL=knowledge.controller.js.map