import { CollaborationMessage, CollaborationMessageSendPayload, MailMessage } from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

const COLLABORATION_MAIL_SUBJECT_PREFIX: string = '[协作会话] ';

function getCollaborationMailSubject(threadId: string): string {
  return `${COLLABORATION_MAIL_SUBJECT_PREFIX}${threadId}`;
}

function isCollaborationRouteUnavailable(error: Error): boolean {
  return error.message.includes('Cannot GET /api/collaboration') ||
    error.message.includes('Cannot POST /api/collaboration');
}

function mapMailToCollaborationMessage(mail: MailMessage, direction: 'in' | 'out'): CollaborationMessage {
  return {
    id: `${direction}-${mail.id}`,
    threadId: mail.subject.slice(COLLABORATION_MAIL_SUBJECT_PREFIX.length),
    senderName: mail.senderName,
    senderRoleLabel: '',
    content: mail.content,
    timeText: mail.createTime,
    direction
  };
}

async function loadMailboxConversation(threadId: string): Promise<CollaborationMessage[]> {
  const subject: string = getCollaborationMailSubject(threadId);
  const inbox: MailMessage[] = await repositories.mailRepository.getInbox();
  const sent: MailMessage[] = await repositories.mailRepository.getSent();
  const messages: CollaborationMessage[] = [];
  inbox.forEach((mail: MailMessage) => {
    if (mail.subject === subject) {
      messages.push(mapMailToCollaborationMessage(mail, 'in'));
    }
  });
  sent.forEach((mail: MailMessage) => {
    if (mail.subject === subject) {
      messages.push(mapMailToCollaborationMessage(mail, 'out'));
    }
  });
  return messages.sort((left: CollaborationMessage, right: CollaborationMessage) => {
    return left.timeText.localeCompare(right.timeText);
  });
}

export async function loadCollaborationMessagesUseCase(threadId: string): Promise<CollaborationMessage[]> {
  try {
    return await repositories.collaborationRepository.getThreadMessages(threadId);
  } catch (error) {
    if (error instanceof Error && isCollaborationRouteUnavailable(error)) {
      return loadMailboxConversation(threadId);
    }
    throw new Error(error instanceof Error ? error.message : '协作消息加载失败。');
  }
}

export async function sendCollaborationMessageUseCase(
  threadId: string,
  receiverIds: string[],
  content: string
): Promise<CollaborationMessage> {
  const payload: CollaborationMessageSendPayload = { threadId, receiverIds, content };
  try {
    return await repositories.collaborationRepository.sendMessage(payload);
  } catch (error) {
    if (!(error instanceof Error) || !isCollaborationRouteUnavailable(error)) {
      throw new Error(error instanceof Error ? error.message : '协作消息发送失败。');
    }
  }

  const mail: MailMessage = await repositories.mailRepository.sendMail({
    receiverIds,
    subject: getCollaborationMailSubject(threadId),
    content,
    relatedWorkflowId: '',
    relatedKnowledgeId: ''
  });
  return mapMailToCollaborationMessage(mail, 'out');
}
