import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import {
  checkIn,
  checkOut,
  getAttendanceRecords,
  getAttendanceToday
} from '../../data/mock-db';

@Controller('attendance')
export class AttendanceController {
  @Get('today')
  getToday(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getAttendanceToday(token));
  }

  @Get('records/my')
  getMyRecords(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getAttendanceRecords(token));
  }

  @Post('check-in')
  checkIn(
    @Headers('authorization') authorization: string | undefined,
    @Body() body: { location: string; note: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(checkIn(token, body.location, body.note), '签到成功');
  }

  @Post('check-out')
  checkOut(
    @Headers('authorization') authorization: string | undefined,
    @Body() body: { location: string; note: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(checkOut(token, body.location, body.note), '签退成功');
  }
}
