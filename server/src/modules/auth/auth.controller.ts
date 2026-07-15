import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import { authenticate, getUserByToken } from '../../data/mock-db';

@Controller('auth')
export class AuthController {
  @Post('login')
  login(@Body() body: { account: string; password: string }) {
    const result = authenticate(body.account, body.password);
    return ok({
      token: result.token,
      user: {
        ...result.user,
        password: ''
      }
    });
  }

  @Get('me')
  getMe(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    const user = getUserByToken(token);
    return ok({
      ...user,
      password: ''
    });
  }

  @Post('logout')
  logout() {
    return ok(null, '退出成功');
  }
}
