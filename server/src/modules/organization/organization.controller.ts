import { Controller, Get, Headers, Query } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import {
  getDepartmentTree,
  getMyOrganization,
  searchOrganizationUsers
} from '../../data/mock-db';

@Controller('organization')
export class OrganizationController {
  @Get('me')
  getMe(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getMyOrganization(token));
  }

  @Get('departments/tree')
  getDepartments(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getDepartmentTree(token));
  }

  @Get('users')
  getUsers(
    @Headers('authorization') authorization?: string,
    @Query('scope') scope: string = 'team',
    @Query('departmentId') departmentId: string = '',
    @Query('keyword') keyword: string = '',
    @Query('activeOnly') activeOnly: string = 'true'
  ) {
    const token: string = getBearerToken(authorization);
    return ok(searchOrganizationUsers(token, scope, departmentId, keyword, activeOnly !== 'false'));
  }
}
