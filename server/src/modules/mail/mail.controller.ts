import { Body, Controller, Delete, Get, Headers, Param, Post } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import {
  deleteMail,
  getInbox,
  getMail,
  getSent,
  markMailRead,
  sendMail
} from '../../data/mock-db';

@Controller('mail')
export class MailController {
  @Get('inbox')
  getInbox(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getInbox(token));
  }

  @Get('sent')
  getSent(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getSent(token));
  }

  @Get(':id')
  getMail(@Headers('authorization') authorization: string | undefined, @Param('id') id: string) {
    const token: string = getBearerToken(authorization);
    return ok(getMail(token, id));
  }

  @Post('send')
  send(
    @Headers('authorization') authorization: string | undefined,
    @Body() body: {
      receiverIds: string[];
      subject: string;
      content: string;
      relatedWorkflowId: string;
      relatedKnowledgeId: string;
    }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(sendMail(token, body), '发送成功');
  }

  @Post(':id/read')
  markRead(@Headers('authorization') authorization: string | undefined, @Param('id') id: string) {
    const token: string = getBearerToken(authorization);
    return ok(markMailRead(token, id), '标记成功');
  }

  @Delete(':id')
  delete(@Headers('authorization') authorization: string | undefined, @Param('id') id: string) {
    const token: string = getBearerToken(authorization);
    return ok(deleteMail(token, id), '删除成功');
  }
}
