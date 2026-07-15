import { Body, Controller, Delete, Get, Headers, Param, Post } from '@nestjs/common';
import { getBearerToken } from '../../common/auth-token';
import { ok } from '../../common/api-response';
import {
  createCorrection,
  favoriteArticle,
  getArticles,
  getCategories,
  unfavoriteArticle
} from '../../data/mock-db';

@Controller('knowledge')
export class KnowledgeController {
  @Get('categories')
  getCategories() {
    return ok(getCategories());
  }

  @Get('articles')
  getArticles(@Headers('authorization') authorization?: string) {
    const token: string = getBearerToken(authorization);
    return ok(getArticles(token));
  }

  @Post('articles/:id/favorite')
  favorite(@Headers('authorization') authorization: string | undefined, @Param('id') id: string) {
    const token: string = getBearerToken(authorization);
    return ok(favoriteArticle(token, id), '收藏成功');
  }

  @Delete('articles/:id/favorite')
  unfavorite(@Headers('authorization') authorization: string | undefined, @Param('id') id: string) {
    const token: string = getBearerToken(authorization);
    return ok(unfavoriteArticle(token, id), '取消收藏成功');
  }

  @Post('articles/:id/corrections')
  createCorrection(
    @Headers('authorization') authorization: string | undefined,
    @Param('id') id: string,
    @Body() body: { content: string }
  ) {
    const token: string = getBearerToken(authorization);
    return ok(createCorrection(token, id, body.content), '提交成功');
  }
}
