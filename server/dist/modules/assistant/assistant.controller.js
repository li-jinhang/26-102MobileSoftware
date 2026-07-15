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
const api_response_1 = require("../../common/api-response");
const mock_db_1 = require("../../data/mock-db");
let AssistantController = class AssistantController {
    ask(body) {
        return (0, api_response_1.ok)((0, mock_db_1.askAssistant)(body.question));
    }
};
exports.AssistantController = AssistantController;
__decorate([
    (0, common_1.Post)('ask'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AssistantController.prototype, "ask", null);
exports.AssistantController = AssistantController = __decorate([
    (0, common_1.Controller)('assistant')
], AssistantController);
//# sourceMappingURL=assistant.controller.js.map