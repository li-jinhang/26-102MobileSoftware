import { Body, Controller, Headers, Post } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import { AssistantService } from './assistant.service';

@Controller('assistant')
export class AssistantController {
  constructor(private readonly assistantService: AssistantService) {
  }

  @Post('analyze')
  async analyze(
    @Headers('authorization') authorization: string | undefined,
    @Body() body: { text: string; imageBase64?: string; imageMimeType?: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(await this.assistantService.analyze(token, {
      text: body.text ?? '',
      imageBase64: body.imageBase64 ?? '',
      imageMimeType: body.imageMimeType ?? ''
    }));
  }
}
