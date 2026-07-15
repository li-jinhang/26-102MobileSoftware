import { Controller, Get, Headers, Param, Post, Query } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import { getNotifications, markNotificationRead } from '../../data/mock-db';

@Controller('notifications')
export class NotificationsController {
  @Get()
  getList(
    @Headers('authorization') authorization?: string,
    @Query('unreadOnly') unreadOnly?: string
  ) {
    const token: string = getBearerToken(authorization);
    return ok(getNotifications(token, unreadOnly === 'true'));
  }

  @Post(':id/read')
  markRead(@Param('id') id: string) {
    return ok(markNotificationRead(id), '标记成功');
  }
}
