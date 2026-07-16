import { BadRequestException, Body, Controller, Headers, PayloadTooLargeException, Post } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import { AssistantService } from './assistant.service';

const MAX_IMAGE_BASE64_LENGTH = 8_000_000;
const IMAGE_MIME_TYPES: string[] = ['', 'image/jpeg', 'image/png'];

interface AnalyzeAssistantRequest {
  text?: unknown;
  imageBase64?: unknown;
  imageMimeType?: unknown;
}

function normalizeAnalyzeRequest(body: AnalyzeAssistantRequest): {
  text: string;
  imageBase64: string;
  imageMimeType: string;
} {
  const text: string = typeof body.text === 'string' ? body.text : '';
  const imageBase64: string = typeof body.imageBase64 === 'string' ? body.imageBase64 : '';
  const imageMimeType: string = typeof body.imageMimeType === 'string' ? body.imageMimeType : '';

  if (text.trim().length === 0 && imageBase64.length === 0) {
    throw new BadRequestException('请至少输入文字或选择一张图片。');
  }
  if (imageBase64.length > MAX_IMAGE_BASE64_LENGTH) {
    throw new PayloadTooLargeException('图片过大，请选择较小的图片。');
  }
  if (imageBase64.length > 0 && !IMAGE_MIME_TYPES.includes(imageMimeType)) {
    throw new BadRequestException('仅支持 JPEG 或 PNG 图片。');
  }
  if (imageBase64.length > 0 && (imageBase64.length % 4 !== 0 || !/^[A-Za-z0-9+/]+={0,2}$/.test(imageBase64))) {
    throw new BadRequestException('图片数据格式无效。');
  }
  return { text, imageBase64, imageMimeType };
}

@Controller('assistant')
export class AssistantController {
  constructor(private readonly assistantService: AssistantService) {
  }

  @Post('analyze')
  async analyze(
    @Headers('authorization') authorization: string | undefined,
    @Body() body: AnalyzeAssistantRequest
  ) {
    const token: string = getBearerToken(authorization);
    return ok(await this.assistantService.analyze(token, normalizeAnalyzeRequest(body)));
  }
}
