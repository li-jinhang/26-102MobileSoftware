"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const assistant_controller_1 = require("./modules/assistant/assistant.controller");
const attendance_controller_1 = require("./modules/attendance/attendance.controller");
const auth_controller_1 = require("./modules/auth/auth.controller");
const knowledge_controller_1 = require("./modules/knowledge/knowledge.controller");
const mail_controller_1 = require("./modules/mail/mail.controller");
const notifications_controller_1 = require("./modules/notifications/notifications.controller");
const organization_controller_1 = require("./modules/organization/organization.controller");
const workflow_controller_1 = require("./modules/workflow/workflow.controller");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        controllers: [
            auth_controller_1.AuthController,
            knowledge_controller_1.KnowledgeController,
            workflow_controller_1.WorkflowController,
            notifications_controller_1.NotificationsController,
            organization_controller_1.OrganizationController,
            assistant_controller_1.AssistantController,
            attendance_controller_1.AttendanceController,
            mail_controller_1.MailController
        ]
    })
], AppModule);
//# sourceMappingURL=app.module.js.map