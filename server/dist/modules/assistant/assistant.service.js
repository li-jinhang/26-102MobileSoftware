"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AssistantService = void 0;
const common_1 = require("@nestjs/common");
const mock_db_1 = require("../../data/mock-db");
function emptyDraft() {
    return { title: '', extra: '', date: '', amount: '', reason: '', attachment: '' };
}
function parseJsonObject(value) {
    const normalized = value.trim().replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim();
    try {
        const parsed = JSON.parse(normalized);
        return typeof parsed === 'object' && parsed !== null && !Array.isArray(parsed) ? parsed : null;
    }
    catch {
        return null;
    }
}
function stringValue(source, key) {
    const value = source[key];
    return typeof value === 'string' ? value.trim() : '';
}
function describeMailMatter(text) {
    return text
        .replace(/请?给(?:我的)?(?:上级|领导|经理|直属负责人|下级|下属|同事|工作组|组员|对接人)?/g, '')
        .replace(/发送?(?:一封)?(?:邮件|信)|发(?:一封)?(?:邮件|信)|写(?:一封)?(?:邮件|信)/g, '')
        .replace(/(?:告诉|告知|通知|说明)(?:他|她|对方|一下)?/g, '')
        .replace(/[，。；;！!？?]/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
}
let AssistantService = class AssistantService {
    async analyze(token, input) {
        const text = input.text.trim();
        const profile = (0, mock_db_1.getMyOrganization)(token);
        const fallback = this.fallbackDecision(text);
        const decision = await this.resolveDecision(text, profile, fallback);
        if (decision.intent === 'mail') {
            const draft = await this.buildMailDraft(text, profile, decision);
            const receiverText = draft.receiverNames.length > 0 ? draft.receiverNames.join('、') : '请选择收件人';
            return {
                answer: draft.receiverIds.length > 0 ? `已为你生成发送给${receiverText}的邮件草稿，请确认后填写。` : '已生成邮件草稿，但未能从组织关系中识别收件人，请手动选择。',
                recognizedText: '',
                intent: 'mail',
                relatedKnowledgeIds: [],
                recommendedWorkflowId: '',
                confidence: 0.86,
                formDraft: emptyDraft(),
                missingFields: draft.receiverIds.length > 0 ? [] : ['收件人'],
                action: { type: 'mail', label: '填写邮件', mailDraft: draft }
            };
        }
        return this.buildWorkflowOrKnowledgeReply(decision.intent);
    }
    fallbackDecision(text) {
        if (/邮件|写信|发信|通知.*(上级|领导|经理|同事)|告知.*(上级|领导|经理|同事)/.test(text)) {
            return { intent: 'mail', recipientHint: text, recipientName: '' };
        }
        if (/请假|病假|年假|事假/.test(text)) {
            return { intent: 'leave', recipientHint: '', recipientName: '' };
        }
        if (/报销|发票|打车|差旅/.test(text)) {
            return { intent: 'reimbursement', recipientHint: '', recipientName: '' };
        }
        if (/采购|预算|合同/.test(text)) {
            return { intent: 'purchase', recipientHint: '', recipientName: '' };
        }
        if (/权限|账号|系统/.test(text)) {
            return { intent: 'permission', recipientHint: '', recipientName: '' };
        }
        return { intent: 'knowledge_query', recipientHint: '', recipientName: '' };
    }
    async resolveDecision(text, profile, fallback) {
        const relationshipContext = [
            profile.manager === null ? '' : `上级：${profile.manager.name}（${profile.manager.jobTitle}）`,
            ...profile.directReports.map((item) => `下级：${item.name}（${item.jobTitle}）`),
            ...profile.departmentMembers.filter((item) => item.id !== profile.employee.id).map((item) => `工作组：${item.name}（${item.jobTitle}）`)
        ].filter((item) => item.length > 0).join('\n');
        const content = await this.callLlm([
            { role: 'system', content: '你是企业助手的意图识别器。仅返回 JSON：{"intent":"mail|leave|reimbursement|purchase|permission|knowledge_query","recipientHint":"上级|下级|工作组|姓名或空","recipientName":"姓名或空"}。不要执行操作。' },
            { role: 'user', content: `员工关系：\n${relationshipContext}\n\n用户需求：${text}` }
        ]);
        if (content === null) {
            return fallback;
        }
        const parsed = parseJsonObject(content);
        if (parsed === null) {
            return fallback;
        }
        const intentValue = stringValue(parsed, 'intent');
        const allowed = ['mail', 'leave', 'reimbursement', 'purchase', 'permission', 'knowledge_query'];
        if (!allowed.includes(intentValue)) {
            return fallback;
        }
        return {
            intent: intentValue,
            recipientHint: stringValue(parsed, 'recipientHint'),
            recipientName: stringValue(parsed, 'recipientName')
        };
    }
    async buildMailDraft(text, profile, decision) {
        const candidates = [
            ...(profile.manager === null ? [] : [profile.manager]),
            ...profile.directReports,
            ...profile.departmentMembers.filter((item) => item.id !== profile.employee.id)
        ];
        const recipientNames = [];
        const receiverIds = [];
        const hint = `${decision.recipientHint} ${decision.recipientName} ${text}`;
        candidates.forEach((item) => {
            const isManager = profile.manager !== null && item.id === profile.manager.id;
            const isDirectReport = profile.directReports.some((report) => report.id === item.id);
            const matchesName = item.name.length > 0 && hint.includes(item.name);
            const matchesManager = isManager && /上级|领导|经理|直属负责人/.test(hint);
            const matchesReport = isDirectReport && /下级|下属/.test(hint);
            const matchesGroup = !isManager && !isDirectReport && /同事|工作组|组员|对接/.test(hint);
            if ((matchesName || matchesManager || matchesReport || matchesGroup) && !receiverIds.includes(item.id)) {
                receiverIds.push(item.id);
                recipientNames.push(item.name);
            }
        });
        const matter = describeMailMatter(text);
        const fallbackSubject = /上班|到岗/.test(text)
            ? '到岗通知'
            : (/新功能.*(?:完成|上线)|(?:完成|上线).*新功能/.test(matter) ? '新功能开发完成' : '工作事项沟通');
        const fallbackContent = /上班|到岗/.test(text)
            ? '您好，\n\n我已到岗上班，特此告知。\n\n谢谢。'
            : `您好，\n\n${matter.length > 0 ? matter : '相关工作事项已处理完毕，现向您汇报。'}\n\n特此向您汇报，请查收。如需进一步说明或配合，我会及时跟进。\n\n谢谢。`;
        const content = await this.callLlm([
            { role: 'system', content: '你是企业邮件草稿助手。将用户的自然语言请求改写为可直接发送的中文内部邮件。仅返回 JSON：{"subject":"不超过20字","content":"完整、礼貌且不复述操作指令的邮件正文"}。不要编造收件人、事项或完成状态。' },
            { role: 'user', content: `用户需求：${text}\n已由系统关系库确定的收件人：${recipientNames.join('、') || '待人工选择'}` }
        ]);
        const parsed = content === null ? null : parseJsonObject(content);
        return {
            receiverIds,
            receiverNames: recipientNames,
            subject: stringValue(parsed !== null && parsed !== void 0 ? parsed : {}, 'subject') || fallbackSubject,
            content: stringValue(parsed !== null && parsed !== void 0 ? parsed : {}, 'content') || fallbackContent
        };
    }
    buildWorkflowOrKnowledgeReply(intent) {
        var _a;
        const mapping = {
            leave: { answer: '已识别为请假事项，可打开请假申请并继续补全时间与原因。', knowledgeId: 'k1', workflowId: 'wf1' },
            reimbursement: { answer: '已识别为报销事项，可打开报销申请并补全发票和事由。', knowledgeId: 'k2', workflowId: 'wf2' },
            purchase: { answer: '已识别为采购事项，可打开采购申请并补全预算与用途。', knowledgeId: 'k3', workflowId: 'wf3' },
            permission: { answer: '已识别为权限事项，可打开权限申请并补全系统与期限。', knowledgeId: 'k4', workflowId: 'wf4' },
            knowledge_query: { answer: '已识别为知识查询，可查看相关制度并选择后续操作。', knowledgeId: 'k1', workflowId: '' }
        };
        const result = (_a = mapping[intent]) !== null && _a !== void 0 ? _a : mapping.knowledge_query;
        return {
            answer: result.answer,
            recognizedText: '',
            intent,
            relatedKnowledgeIds: [result.knowledgeId],
            recommendedWorkflowId: result.workflowId,
            confidence: 0.72,
            formDraft: emptyDraft(),
            missingFields: [],
            action: { type: result.workflowId.length > 0 ? 'workflow' : 'knowledge', label: '', mailDraft: null }
        };
    }
    async callLlm(messages) {
        var _a, _b, _c;
        const baseUrl = (_a = process.env.LLM_BASE_URL) !== null && _a !== void 0 ? _a : '';
        const apiKey = (_b = process.env.LLM_API_KEY) !== null && _b !== void 0 ? _b : '';
        const model = (_c = process.env.LLM_MODEL) !== null && _c !== void 0 ? _c : '';
        if (baseUrl.length === 0 || apiKey.length === 0 || model.length === 0) {
            return null;
        }
        try {
            const response = await fetch(`${baseUrl.replace(/\/$/, '')}/chat/completions`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
                body: JSON.stringify({ model, temperature: 0.2, messages })
            });
            if (!response.ok) {
                return null;
            }
            const payload = await response.json();
            if (typeof payload !== 'object' || payload === null || !('choices' in payload)) {
                return null;
            }
            const choices = payload.choices;
            if (!Array.isArray(choices) || choices.length === 0 || typeof choices[0] !== 'object' || choices[0] === null) {
                return null;
            }
            const message = choices[0].message;
            if (typeof message !== 'object' || message === null) {
                return null;
            }
            const content = message.content;
            return typeof content === 'string' ? content : null;
        }
        catch {
            return null;
        }
    }
};
exports.AssistantService = AssistantService;
exports.AssistantService = AssistantService = __decorate([
    (0, common_1.Injectable)()
], AssistantService);
//# sourceMappingURL=assistant.service.js.map