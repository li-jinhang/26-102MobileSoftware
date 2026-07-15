import { Body, Controller, Get, Headers, Param, Post } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import {
  approveWorkflow,
  createWorkflow,
  getMyWorkflowInstances,
  getTodoWorkflowInstances,
  getWorkflowInstanceById,
  getWorkflowTemplates,
  rejectWorkflow,
  securityConfirmWorkflow
} from '../../data/mock-db';

@Controller('workflow')
export class WorkflowController {
  @Get('templates')
  getTemplates() {
    return ok(getWorkflowTemplates());
  }

  @Get('instances/my')
  getMyInstances(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getMyWorkflowInstances(token));
  }

  @Get('instances/todo')
  getTodoInstances(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getTodoWorkflowInstances(token));
  }

  @Get('instances/:id')
  getInstance(@Param('id') id: string) {
    return ok(getWorkflowInstanceById(id));
  }

  @Post('instances')
  create(
    @Headers('authorization') authorization: string | undefined,
    @Body() body: {
      templateId: string;
      title: string;
      extraInput: string;
      dateInput: string;
      amountInput: number;
      reasonInput: string;
      attachmentInput: string;
    }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(createWorkflow(token, body), '提交流程成功');
  }

  @Post('instances/:id/approve')
  approve(
    @Headers('authorization') authorization: string | undefined,
    @Param('id') id: string,
    @Body() body: { comment: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(approveWorkflow(token, id, body.comment), '审批成功');
  }

  @Post('instances/:id/reject')
  reject(
    @Headers('authorization') authorization: string | undefined,
    @Param('id') id: string,
    @Body() body: { comment: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(rejectWorkflow(token, id, body.comment), '驳回成功');
  }

  @Post('instances/:id/security-confirm')
  securityConfirm(
    @Headers('authorization') authorization: string | undefined,
    @Param('id') id: string,
    @Body() body: { comment: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(securityConfirmWorkflow(token, id, body.comment), '确认成功');
  }
}
