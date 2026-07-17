import {
  AssistantAnalyzeInput,
  AssistantHistory,
  AssistantMailDraft,
  AssistantReply,
  EmployeeDirectoryItem,
  OrganizationProfile
} from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export interface AssistantAskResult {
  success: boolean;
  reply: AssistantReply | null;
  history: AssistantHistory[];
  message: string;
}

export async function askAssistantUseCase(
  input: AssistantAnalyzeInput,
  history: AssistantHistory[]
): Promise<AssistantAskResult> {
  const normalized: string = input.text.trim();
  if (normalized.length === 0 && input.imageBase64.length === 0) {
    return {
      success: false,
      reply: null,
      history,
      message: '请输入问题后再提问。'
    };
  }

  const request: AssistantAnalyzeInput = {
    text: normalized,
    imageBase64: input.imageBase64,
    imageMimeType: input.imageMimeType
  };
  const reply: AssistantReply = await repositories.assistantRepository.analyze(request);
  const historyQuestion: string = normalized.length > 0
    ? normalized
    : (reply.recognizedText.length > 0 ? `图片查询：${reply.recognizedText.slice(0, 60)}` : '图片查询');
  return {
    success: true,
    reply,
    history: [
      {
        id: `${Date.now()}`,
        question: historyQuestion,
        answer: reply.answer,
        time: '刚刚'
      },
      ...history
    ],
    message: ''
  };
}

function isExplicitMailRequest(text: string): boolean {
  return /邮件|写信|发信|发邮件|写邮件/.test(text);
}

function getMailMatter(text: string, receiverNames: string[]): string {
  let matter: string = text;
  receiverNames.forEach((name: string) => {
    matter = matter.split(name).join('');
  });
  return matter
    .replace(/请?给(?:我的)?(?:上级|领导|经理|直属负责人|下级|下属|同事|工作组|组员|对接人)?/g, '')
    .replace(/发送?(?:一封)?(?:邮件|信)|发(?:一封)?(?:邮件|信)|写(?:一封)?(?:邮件|信)/g, '')
    .replace(/(?:告诉|告知|通知|说明)(?:他|她|对方|一下)?/g, '')
    .replace(/[，。；;！!？?]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Compatibility fallback for an older assistant endpoint that returns prose but no structured mail action.
 */
export function buildCompatibilityMailDraftUseCase(
  text: string,
  profile: OrganizationProfile | null
): AssistantMailDraft | null {
  if (!isExplicitMailRequest(text) || profile === null) {
    return null;
  }
  const candidates: EmployeeDirectoryItem[] = [];
  if (profile.manager !== null) {
    candidates.push(profile.manager);
  }
  profile.directReports.concat(profile.departmentMembers).forEach((item: EmployeeDirectoryItem) => {
    if (item.id !== profile.employee.id && !candidates.some((candidate: EmployeeDirectoryItem) => candidate.id === item.id)) {
      candidates.push(item);
    }
  });
  const receiver: EmployeeDirectoryItem | undefined = candidates.find((item: EmployeeDirectoryItem) => text.includes(item.name)) ??
    (profile.manager !== null && /上级|领导|经理|直属负责人/.test(text) ? profile.manager : undefined);
  if (receiver === undefined) {
    return null;
  }
  const matter: string = getMailMatter(text, [receiver.name]);
  const subject: string = /新(?:的)?功能.*(?:完成|上线)|(?:完成|上线).*新(?:的)?功能/.test(matter)
    ? '新功能开发完成'
    : '工作事项沟通';
  return {
    receiverIds: [receiver.id],
    receiverNames: [receiver.name],
    subject,
    content: `您好，\n\n${matter.length > 0 ? matter : '相关工作事项已处理完毕，现向您汇报。'}\n\n特此向您汇报，请查收。如需进一步说明或配合，我会及时跟进。\n\n谢谢。`
  };
}
