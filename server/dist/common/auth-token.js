"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBearerToken = getBearerToken;
function getBearerToken(authorization) {
    if (authorization === undefined || authorization.length === 0) {
        throw new Error('未登录或 Token 无效');
    }
    return authorization.replace('Bearer ', '').trim();
}
//# sourceMappingURL=auth-token.js.map