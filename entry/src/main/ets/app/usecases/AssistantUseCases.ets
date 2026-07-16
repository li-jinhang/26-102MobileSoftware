import { AssistantAnalyzeInput, AssistantHistory, AssistantReply } from '../../models/AppModels';
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
