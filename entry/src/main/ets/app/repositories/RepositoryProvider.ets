import {
  AttendanceRepository,
  AssistantRepository,
  AuditRepository,
  AuthRepository,
  KnowledgeRepository,
  MailRepository,
  NotificationRepository,
  OrganizationRepository,
  WorkflowRepository
} from '../../domain/contracts/AppRepositories';
import {
  httpAttendanceRepository,
  httpAssistantRepository,
  httpAuditRepository,
  httpAuthRepository,
  httpKnowledgeRepository,
  httpMailRepository,
  httpNotificationRepository,
  httpOrganizationRepository,
  httpWorkflowRepository
} from '../../http/adapters/HttpRepositories';

export interface RepositoryBundle {
  authRepository: AuthRepository;
  knowledgeRepository: KnowledgeRepository;
  workflowRepository: WorkflowRepository;
  notificationRepository: NotificationRepository;
  organizationRepository: OrganizationRepository;
  attendanceRepository: AttendanceRepository;
  mailRepository: MailRepository;
  assistantRepository: AssistantRepository;
  auditRepository: AuditRepository;
}

export const repositories: RepositoryBundle = {
  authRepository: httpAuthRepository,
  knowledgeRepository: httpKnowledgeRepository,
  workflowRepository: httpWorkflowRepository,
  notificationRepository: httpNotificationRepository,
  organizationRepository: httpOrganizationRepository,
  attendanceRepository: httpAttendanceRepository,
  mailRepository: httpMailRepository,
  assistantRepository: httpAssistantRepository,
  auditRepository: httpAuditRepository
};
