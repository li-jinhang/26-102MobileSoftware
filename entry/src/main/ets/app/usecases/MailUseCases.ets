import { repositories } from '../repositories/RepositoryProvider';
import { MailFolder, MailMessage } from '../../models/AppModels';

export interface MailboxData {
  inbox: MailMessage[];
  sent: MailMessage[];
}

function sortMailByTime(messages: MailMessage[]): MailMessage[] {
  return messages.slice().sort((left: MailMessage, right: MailMessage) => {
    return right.createTime.localeCompare(left.createTime);
  });
}

export async function loadMailBoxUseCase(): Promise<MailboxData> {
  const inbox: MailMessage[] = await repositories.mailRepository.getInbox();
  const sent: MailMessage[] = await repositories.mailRepository.getSent();
  return {
    inbox: sortMailByTime(inbox),
    sent: sortMailByTime(sent)
  };
}

export function getMailListByFolderUseCase(mailbox: MailboxData, folder: MailFolder): MailMessage[] {
  if (folder === 'sent') {
    return mailbox.sent;
  }
  if (folder === 'trash') {
    return [];
  }
  if (folder === 'draft') {
    return [];
  }
  return mailbox.inbox;
}

export function getUnreadMailCountUseCase(mailbox: MailboxData): number {
  return mailbox.inbox.filter((item: MailMessage) => !item.read).length;
}

export async function sendInternalMailUseCase(
  receiverIds: string[],
  subject: string,
  content: string,
  relatedWorkflowId: string,
  relatedKnowledgeId: string
): Promise<MailMessage> {
  return repositories.mailRepository.sendMail({
    receiverIds,
    subject: subject.trim(),
    content: content.trim(),
    relatedWorkflowId,
    relatedKnowledgeId
  });
}

export async function markMailReadUseCase(mailId: string): Promise<void> {
  await repositories.mailRepository.markRead(mailId);
}

export async function deleteMailUseCase(mailId: string): Promise<void> {
  await repositories.mailRepository.deleteMail(mailId);
}
