import { CollaborationBoard, CollaborationItem, EmployeeDirectoryItem, OrganizationProfile, User, WorkflowInstance } from '../../models/AppModels';

function isPendingWorkflow(item: WorkflowInstance): boolean {
  return item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认';
}

function countMyPendingWorkflows(currentUser: User | null, workflowInstances: WorkflowInstance[]): number {
  if (currentUser === null) {
    return 0;
  }

  return workflowInstances.filter((item: WorkflowInstance) => {
    return item.applicantId === currentUser.id && isPendingWorkflow(item);
  }).length;
}

function countActionWorkflows(currentUser: User | null, workflowInstances: WorkflowInstance[]): number {
  if (currentUser === null) {
    return 0;
  }

  return workflowInstances.filter((item: WorkflowInstance) => {
    return item.currentApproverRole === currentUser.role && isPendingWorkflow(item);
  }).length;
}

function buildMeetingItems(currentUser: User, profile: OrganizationProfile | null): CollaborationItem[] {
  const departmentName: string = currentUser.department.length > 0 ? currentUser.department : '所属部门';
  const managerName: string = profile !== null && profile.manager !== null ? profile.manager.name : '直属负责人';
  return [
    {
      id: 'meet-1',
      kind: 'meeting',
      title: `${departmentName} 周会`,
      summary: `围绕 ${departmentName} 的短期目标同步最新进度。`,
      ownerName: managerName,
      ownerDepartment: departmentName,
      timeText: '周三 09:30',
      placeText: 'A 栋 3 层协作室',
      statusText: '待确认',
      state: 'action',
      needsAction: true
    },
    {
      id: 'meet-2',
      kind: 'meeting',
      title: '跨部门对接会',
      summary: '用于和相关支持团队快速对齐排期与风险。',
      ownerName: '项目协同组',
      ownerDepartment: '协同中心',
      timeText: '周五 15:00',
      placeText: '线上会议',
      statusText: '已排期',
      state: 'active',
      needsAction: false
    }
  ];
}

function buildTaskItems(currentUser: User, profile: OrganizationProfile | null, workflowInstances: WorkflowInstance[]): CollaborationItem[] {
  const managerName: string = profile !== null && profile.manager !== null ? profile.manager.name : '直属负责人';
  const reportCount: number = profile === null ? 0 : profile.directReports.length;
  const actionWorkflowCount: number = countActionWorkflows(currentUser, workflowInstances);
  const waitingWorkflowCount: number = countMyPendingWorkflows(currentUser, workflowInstances);
  return [
    {
      id: 'task-1',
      kind: 'task',
      title: '短期工作对接请求',
      summary: `${managerName} 发起了本周协作对接，需要你回复确认优先级与交付时间。`,
      ownerName: managerName,
      ownerDepartment: currentUser.department,
      timeText: '今天 18:00 前',
      placeText: '消息中心',
      statusText: actionWorkflowCount > 0 ? `待处理 ${actionWorkflowCount} 项` : '待回复',
      state: 'action',
      needsAction: true
    },
    {
      id: 'task-2',
      kind: 'task',
      title: '我发起的协作请求',
      summary: reportCount > 0 ? `当前有 ${reportCount} 位直接下属可继续跟进。` : '已发起的协作会在这里等待对方确认。',
      ownerName: currentUser.name,
      ownerDepartment: currentUser.department,
      timeText: '持续跟进',
      placeText: '工作台',
      statusText: waitingWorkflowCount > 0 ? `等待中 ${waitingWorkflowCount} 项` : '等待中',
      state: 'waiting',
      needsAction: false
    }
  ];
}

function buildGroupItems(currentUser: User, profile: OrganizationProfile | null): CollaborationItem[] {
  const membersText: string = profile === null ? '0 人' : `${profile.departmentMembers.length} 人`;
  return [
    {
      id: 'group-1',
      kind: 'group',
      title: `${currentUser.department} 协作组`,
      summary: `面向 ${membersText} 的短周期推进与任务分配。`,
      ownerName: currentUser.name,
      ownerDepartment: currentUser.department,
      timeText: '长期存在',
      placeText: '协作页',
      statusText: '活跃',
      state: 'active',
      needsAction: false
    },
    {
      id: 'group-2',
      kind: 'group',
      title: '跨部门对接群',
      summary: '用于临时拉通支持团队、共享进度和快速确认依赖。',
      ownerName: currentUser.name,
      ownerDepartment: currentUser.department,
      timeText: '临时创建',
      placeText: '协作页',
      statusText: '待启用',
      state: 'active',
      needsAction: false
    }
  ];
}

function buildChainItems(profile: OrganizationProfile | null): CollaborationItem[] {
  if (profile === null) {
    return [];
  }

  const items: CollaborationItem[] = [];
  if (profile.manager !== null) {
    const managerItem: CollaborationItem = {
      id: 'chain-manager',
      kind: 'chain',
      title: '直属上级',
      summary: `${profile.manager.name} · ${profile.manager.jobTitle}`,
      ownerName: profile.manager.name,
      ownerDepartment: profile.manager.departmentName,
      timeText: '随时可联系',
      placeText: '组织关系',
      statusText: '可直联',
      state: 'active',
      needsAction: false
    };
    items.push(managerItem);
  }

  profile.directReports.forEach((item: EmployeeDirectoryItem, index: number) => {
    const chainItem: CollaborationItem = {
      id: `chain-report-${index}`,
      kind: 'chain',
      title: item.name,
      summary: `${item.jobTitle} · ${item.departmentName}`,
      ownerName: item.name,
      ownerDepartment: item.departmentName,
      timeText: '可协同',
      placeText: '直接下属',
      statusText: '可对接',
      state: 'active',
      needsAction: false
    };
    items.push(chainItem);
  });

  return items;
}

export function buildCollaborationBoardUseCase(
  currentUser: User | null,
  profile: OrganizationProfile | null,
  workflowInstances: WorkflowInstance[]
): CollaborationBoard {
  if (currentUser === null) {
    return {
      actionCount: 0,
      waitingCount: 0,
      meetingCount: 0,
      groupCount: 0,
      meetingItems: [],
      taskItems: [],
      groupItems: [],
      chainItems: []
    };
  }

  const meetingItems: CollaborationItem[] = buildMeetingItems(currentUser, profile);
  const taskItems: CollaborationItem[] = buildTaskItems(currentUser, profile, workflowInstances);
  const groupItems: CollaborationItem[] = buildGroupItems(currentUser, profile);
  const chainItems: CollaborationItem[] = buildChainItems(profile);

  const actionWorkflowCount: number = countActionWorkflows(currentUser, workflowInstances);
  const waitingWorkflowCount: number = countMyPendingWorkflows(currentUser, workflowInstances);
  const actionCount: number = actionWorkflowCount + taskItems.filter((item: CollaborationItem) => item.needsAction).length;
  const waitingCount: number = waitingWorkflowCount + taskItems.filter((item: CollaborationItem) => item.state === 'waiting').length;

  return {
    actionCount,
    waitingCount,
    meetingCount: meetingItems.length,
    groupCount: groupItems.length,
    meetingItems,
    taskItems,
    groupItems,
    chainItems
  };
}
