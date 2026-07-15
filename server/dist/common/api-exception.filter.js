"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ApiExceptionFilter = void 0;
const common_1 = require("@nestjs/common");
let ApiExceptionFilter = class ApiExceptionFilter {
    catch(exception, host) {
        const response = host.switchToHttp().getResponse();
        if (exception instanceof common_1.HttpException) {
            response.status(exception.getStatus()).json({
                code: this.mapErrorCode(exception.getStatus()),
                message: exception.message,
                data: null
            });
            return;
        }
        const message = exception instanceof Error ? exception.message : '服务器内部错误';
        response.status(common_1.HttpStatus.INTERNAL_SERVER_ERROR).json({
            code: 1007,
            message,
            data: null
        });
    }
    mapErrorCode(status) {
        if (status === common_1.HttpStatus.UNAUTHORIZED) {
            return 1002;
        }
        if (status === common_1.HttpStatus.FORBIDDEN) {
            return 1003;
        }
        if (status === common_1.HttpStatus.NOT_FOUND) {
            return 1004;
        }
        if (status === common_1.HttpStatus.BAD_REQUEST) {
            return 1001;
        }
        return 1007;
    }
};
exports.ApiExceptionFilter = ApiExceptionFilter;
exports.ApiExceptionFilter = ApiExceptionFilter = __decorate([
    (0, common_1.Catch)()
], ApiExceptionFilter);
//# sourceMappingURL=api-exception.filter.js.map