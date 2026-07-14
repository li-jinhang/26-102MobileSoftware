import {
  AssistantRepository,
  AuditRepository,
  AuthRepository,
  KnowledgeRepository,
  NotificationRepository,
  WorkflowRepository
} from '../../domain/contracts/AppRepositories';
import {
  httpAssistantRepository,
  httpAuditRepository,
  httpAuthRepository,
  httpKnowledgeRepository,
  httpNotificationRepository,
  httpWorkflowRepository
} from '../../http/adapters/HttpRepositories';

export interface RepositoryBundle {
  authRepository: AuthRepository;
  knowledgeRepository: KnowledgeRepository;
  workflowRepository: WorkflowRepository;
  notificationRepository: NotificationRepository;
  assistantRepository: AssistantRepository;
  auditRepository: AuditRepository;
}

export const repositories: RepositoryBundle = {
  authRepository: httpAuthRepository,
  knowledgeRepository: httpKnowledgeRepository,
  workflowRepository: httpWorkflowRepository,
  notificationRepository: httpNotificationRepository,
  assistantRepository: httpAssistantRepository,
  auditRepository: httpAuditRepository
};
