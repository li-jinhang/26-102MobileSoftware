import { describe, expect, it } from '@ohos/hypium';
import { KnowledgeArticle, NotificationItem } from '../main/ets/models/AppModels';
import {
  filterPublishedArticles,
  searchKnowledge,
  validateCorrection
} from '../main/ets/common/services/KnowledgeService';
import { buildAssistantReply } from '../main/ets/common/services/AssistantService';
import {
  filterNotifications,
  markNotificationRead
} from '../main/ets/common/services/MessageService';
import { buildCollaborationBoardUseCase } from '../main/ets/app/usecases/CollaborationUseCases';
import { User } from '../main/ets/models/AppModels';

export default function localUnitTest() {
  describe('memberAServiceTest', () => {
    const published: KnowledgeArticle = {
      id: 'k1',
      title: '差旅报销制度',
      summary: '发票规范',
      content: '正文',
      categoryId: 'c2',
      categoryName: '财务报销',
      tags: ['报销'],
      updateTime: '2026-07-13',
      version: 'v1.0',
      status: 'published',
      attachments: [],
      relatedWorkflowIds: ['wf2']
    };
    const removed: KnowledgeArticle = {
      id: 'k2',
      title: '旧制度',
      summary: '旧内容',
      content: '正文',
      categoryId: 'c2',
      categoryName: '财务报销',
      tags: ['废止'],
      updateTime: '2026-07-01',
      version: 'v0.9',
      status: 'removed',
      attachments: [],
      relatedWorkflowIds: []
    };

    it('filters non-published knowledge', 0, () => {
      expect(filterPublishedArticles([published, removed]).length).assertEqual(1);
    });

    it('combines category and keyword search', 0, () => {
      expect(searchKnowledge([published, removed], 'c2', ' 发票 ').length).assertEqual(1);
      expect(searchKnowledge([published, removed], 'c1', '发票').length).assertEqual(0);
    });

    it('validates correction text', 0, () => {
      expect(validateCorrection('   ')).assertEqual('');
      expect(validateCorrection(' 日期已经过期 ')).assertEqual('日期已经过期');
    });

    it('rejects empty assistant input', 0, () => {
      expect(buildAssistantReply('   ')).assertNull();
      const reply = buildAssistantReply('打车费怎么报销');
      expect(reply === null ? '' : reply.recommendedWorkflowId).assertEqual('wf2');
    });

    it('filters unread messages and marks one read immutably', 0, () => {
      const message: NotificationItem = {
        id: 'n1',
        title: '更新',
        content: '内容',
        time: '现在',
        read: false,
        targetRoles: ['employee'],
        targetType: 'knowledge',
        targetId: 'k1'
      };
      expect(filterNotifications([message], true).length).assertEqual(1);
      expect(markNotificationRead([message], 'n1')[0].read).assertTrue();
      expect(message.read).assertFalse();
    });

    it('updates meeting and task statuses from linked collaboration state', 0, () => {
      const user: User = {
        id: 'u1',
        name: '张晓宁',
        account: 'employee01',
        department: '产品研发部',
        departmentId: 'd-product',
        jobTitle: '产品专员',
        managerId: 'u2',
        employmentStatus: 'active',
        role: 'employee',
        roleLabel: '普通员工'
      };
      const board = buildCollaborationBoardUseCase(user, null, [], [], ['meet-1'], [], ['task-1']);
      const meeting = board.meetingItems.find((item) => item.id === 'meet-1');
      const task = board.taskItems.find((item) => item.id === 'task-1');

      expect(meeting === undefined ? '' : meeting.statusText).assertEqual('已确认');
      expect(meeting === undefined ? true : meeting.needsAction).assertFalse();
      expect(task === undefined ? '' : task.statusText).assertEqual('已同意');
      expect(task === undefined ? true : task.needsAction).assertFalse();
    });
  });
}
