"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const api_exception_filter_1 = require("./common/api-exception.filter");
async function bootstrap() {
    var _a;
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.setGlobalPrefix('api');
    app.enableCors();
    app.useGlobalFilters(new api_exception_filter_1.ApiExceptionFilter());
    const port = Number((_a = process.env.PORT) !== null && _a !== void 0 ? _a : '26102');
    await app.listen(port, '0.0.0.0');
    console.log(`MobileSoftwareBackend listening on http://127.0.0.1:${port}/api`);
}
void bootstrap();
//# sourceMappingURL=main.js.map