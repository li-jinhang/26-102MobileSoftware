import { Module } from '@nestjs/common';
import { AssistantController } from './modules/assistant/assistant.controller';
import { AssistantService } from './modules/assistant/assistant.service';
import { AttendanceController } from './modules/attendance/attendance.controller';
import { CollaborationController } from './modules/collaboration/collaboration.controller';
import { AuthController } from './modules/auth/auth.controller';
import { KnowledgeController } from './modules/knowledge/knowledge.controller';
import { MailController } from './modules/mail/mail.controller';
import { NotificationsController } from './modules/notifications/notifications.controller';
import { OrganizationController } from './modules/organization/organization.controller';
import { WorkflowController } from './modules/workflow/workflow.controller';

@Module({
  controllers: [
    AuthController,
    KnowledgeController,
    WorkflowController,
    NotificationsController,
    OrganizationController,
    AssistantController,
    AttendanceController,
    MailController,
    CollaborationController
  ],
  providers: [AssistantService]
})
export class AppModule {
}
