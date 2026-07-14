import { AssistantHistory, AssistantReply } from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export interface AssistantAskResult {
  success: boolean;
  reply: AssistantReply | null;
  history: AssistantHistory[];
  message: string;
}

export async function askAssistantUseCase(
  question: string,
  history: AssistantHistory[]
): Promise<AssistantAskResult> {
  const normalized: string = question.trim();
  if (normalized.length === 0) {
    return {
      success: false,
      reply: null,
      history,
      message: '请输入问题后再提问。'
    };
  }

  const reply: AssistantReply = await repositories.assistantRepository.ask(normalized);
  return {
    success: true,
    reply,
    history: [
      {
        id: `${Date.now()}`,
        question: normalized,
        answer: reply.answer,
        time: '刚刚'
      },
      ...history
    ],
    message: ''
  };
}
