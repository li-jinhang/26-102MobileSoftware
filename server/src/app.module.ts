import { Module } from '@nestjs/common';
import { AssistantController } from './modules/assistant/assistant.controller';
import { AttendanceController } from './modules/attendance/attendance.controller';
import { AuthController } from './modules/auth/auth.controller';
import { KnowledgeController } from './modules/knowledge/knowledge.controller';
import { MailController } from './modules/mail/mail.controller';
import { NotificationsController } from './modules/notifications/notifications.controller';
import { WorkflowController } from './modules/workflow/workflow.controller';

@Module({
  controllers: [
    AuthController,
    KnowledgeController,
    WorkflowController,
    NotificationsController,
    AssistantController,
    AttendanceController,
    MailController
  ]
})
export class AppModule {
}
