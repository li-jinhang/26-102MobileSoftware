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
exports.AssistantController = void 0;
const common_1 = require("@nestjs/common");
const auth_token_1 = require("../../common/auth-token");
const api_response_1 = require("../../common/api-response");
const assistant_service_1 = require("./assistant.service");
const MAX_IMAGE_BASE64_LENGTH = 8000000;
const IMAGE_MIME_TYPES = ['', 'image/jpeg', 'image/png'];
function normalizeAnalyzeRequest(body) {
    const text = typeof body.text === 'string' ? body.text : '';
    const imageBase64 = typeof body.imageBase64 === 'string' ? body.imageBase64 : '';
    const imageMimeType = typeof body.imageMimeType === 'string' ? body.imageMimeType : '';
    if (text.trim().length === 0 && imageBase64.length === 0) {
        throw new common_1.BadRequestException('请至少输入文字或选择一张图片。');
    }
    if (imageBase64.length > MAX_IMAGE_BASE64_LENGTH) {
        throw new common_1.PayloadTooLargeException('图片过大，请选择较小的图片。');
    }
    if (imageBase64.length > 0 && !IMAGE_MIME_TYPES.includes(imageMimeType)) {
        throw new common_1.BadRequestException('仅支持 JPEG 或 PNG 图片。');
    }
    if (imageBase64.length > 0 && (imageBase64.length % 4 !== 0 || !/^[A-Za-z0-9+/]+={0,2}$/.test(imageBase64))) {
        throw new common_1.BadRequestException('图片数据格式无效。');
    }
    return { text, imageBase64, imageMimeType };
}
let AssistantController = class AssistantController {
    constructor(assistantService) {
        this.assistantService = assistantService;
    }
    async analyze(authorization, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)(await this.assistantService.analyze(token, normalizeAnalyzeRequest(body)));
    }
};
exports.AssistantController = AssistantController;
__decorate([
    (0, common_1.Post)('analyze'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], AssistantController.prototype, "analyze", null);
exports.AssistantController = AssistantController = __decorate([
    (0, common_1.Controller)('assistant'),
    __metadata("design:paramtypes", [assistant_service_1.AssistantService])
], AssistantController);
//# sourceMappingURL=assistant.controller.js.map