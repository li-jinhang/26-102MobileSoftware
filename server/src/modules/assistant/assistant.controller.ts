import { Body, Controller, Post } from '@nestjs/common';
import { ok } from '../../common/api-response';
import { askAssistant } from '../../data/mock-db';

@Controller('assistant')
export class AssistantController {
  @Post('ask')
  ask(@Body() body: { question: string }) {
    return ok(askAssistant(body.question));
  }
}
