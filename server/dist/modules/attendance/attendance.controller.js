"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AttendanceController = void 0;
const common_1 = require("@nestjs/common");
const auth_token_1 = require("../../common/auth-token");
const api_response_1 = require("../../common/api-response");
const mock_db_1 = require("../../data/mock-db");
let AttendanceController = class AttendanceController {
    getToday(authorization) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getAttendanceToday)(token));
    }
    getMyRecords(authorization) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.getAttendanceRecords)(token));
    }
    checkIn(authorization, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.checkIn)(token, body.location, body.note), '签到成功');
    }
    checkOut(authorization, body) {
        const token = (0, auth_token_1.getBearerToken)(authorization);
        return (0, api_response_1.ok)((0, mock_db_1.checkOut)(token, body.location, body.note), '签退成功');
    }
};
exports.AttendanceController = AttendanceController;
__decorate([
    (0, common_1.Get)('today'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AttendanceController.prototype, "getToday", null);
__decorate([
    (0, common_1.Get)('records/my'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AttendanceController.prototype, "getMyRecords", null);
__decorate([
    (0, common_1.Post)('check-in'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], AttendanceController.prototype, "checkIn", null);
__decorate([
    (0, common_1.Post)('check-out'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], AttendanceController.prototype, "checkOut", null);
exports.AttendanceController = AttendanceController = __decorate([
    (0, common_1.Controller)('attendance')
], AttendanceController);
//# sourceMappingURL=attendance.controller.js.map