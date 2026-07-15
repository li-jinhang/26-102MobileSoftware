import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse();

    if (exception instanceof HttpException) {
      response.status(exception.getStatus()).json({
        code: this.mapErrorCode(exception.getStatus()),
        message: exception.message,
        data: null
      });
      return;
    }

    const message: string = exception instanceof Error ? exception.message : '服务器内部错误';
    response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      code: 1007,
      message,
      data: null
    });
  }

  private mapErrorCode(status: number): number {
    if (status === HttpStatus.UNAUTHORIZED) {
      return 1002;
    }
    if (status === HttpStatus.FORBIDDEN) {
      return 1003;
    }
    if (status === HttpStatus.NOT_FOUND) {
      return 1004;
    }
    if (status === HttpStatus.BAD_REQUEST) {
      return 1001;
    }
    return 1007;
  }
}
