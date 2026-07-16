import { Body, Controller, Get, Headers, Param, Post, Query } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import { getCollaborationMessages, sendCollaborationMessage } from '../../data/mock-db';

@Controller('collaboration')
export class CollaborationController {
  @Get('messages')
  getMessages(
    @Headers('authorization') authorization: string | undefined,
    @Query('threadId') threadId: string = ''
  ) {
    const token: string = getBearerToken(authorization);
    return ok(getCollaborationMessages(token, threadId));
  }

  @Post('threads/:threadId/messages')
  sendMessage(
    @Headers('authorization') authorization: string | undefined,
    @Param('threadId') threadId: string,
    @Body() body: { receiverIds: string[]; content: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(sendCollaborationMessage(token, threadId, body), '消息已发送');
  }
}
