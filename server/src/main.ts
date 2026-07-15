import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/api-exception.filter';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');
  app.enableCors();
  app.useGlobalFilters(new ApiExceptionFilter());

  const port: number = Number(process.env.PORT ?? '26102');
  await app.listen(port, '0.0.0.0');
  console.log(`MobileSoftwareBackend listening on http://127.0.0.1:${port}/api`);
}

void bootstrap();
