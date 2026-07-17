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
      needsAction: true,
      participantIds: profile === null ? [] : profile.departmentMembers.map((item: EmployeeDirectoryItem) => item.id),
      members: profile === null ? [] : profile.departmentMembers
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
      needsAction: false,
      participantIds: [],
      members: []
    }
  ];
}

function buildTaskItems(currentUser: User, profile: OrganizationProfile | null, workflowInstances: WorkflowInstance[]): CollaborationItem[] {
  const managerName: string = profile !== null && profile.manager !== null ? profile.manager.name : '直属负责人';
  const reportCount: number = profile === null ? 0 : profile.directReports.length;
  const actionWorkflowCount: number = countActionWorkflows(currentUser, workflowInstances);
  const waitingWorkflowCount: number = countMyPendingWorkflows(currentUser, workflowInstances);
  const managerParticipants: EmployeeDirectoryItem[] = profile === null || profile.manager === null ? [] : [profile.manager];
  const reportParticipants: EmployeeDirectoryItem[] = profile === null ? [] : profile.directReports;
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
      needsAction: true,
      participantIds: managerParticipants.map((item: EmployeeDirectoryItem) => item.id),
      members: managerParticipants
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
      needsAction: false,
      participantIds: reportParticipants.map((item: EmployeeDirectoryItem) => item.id),
      members: reportParticipants
    }
  ];
}

function copyTaskWithStatus(
  item: CollaborationItem,
  statusText: string,
  state: 'action' | 'waiting' | 'active',
  needsAction: boolean
): CollaborationItem {
  return {
    id: item.id,
    kind: item.kind,
    title: item.title,
    summary: item.summary,
    ownerName: item.ownerName,
    ownerDepartment: item.ownerDepartment,
    timeText: item.timeText,
    placeText: item.placeText,
    statusText,
    state,
    needsAction,
    participantIds: item.participantIds,
    members: item.members
  };
}

function buildCustomTaskItems(
  currentUser: User,
  customTaskItems: CollaborationItem[],
  acceptedTaskIds: string[]
): CollaborationItem[] {
  const items: CollaborationItem[] = [];
  customTaskItems.forEach((item: CollaborationItem) => {
    const accepted: boolean = acceptedTaskIds.includes(item.id);
    if (item.ownerName === currentUser.name) {
      items.push(copyTaskWithStatus(item, accepted ? '已同意' : '等待同意', accepted ? 'active' : 'waiting', false));
      return;
    }
    if (item.participantIds.includes(currentUser.id)) {
      items.push(copyTaskWithStatus(item, accepted ? '已同意' : '待同意', accepted ? 'active' : 'action', !accepted));
    }
  });
  return items;
}

function buildGroupItems(currentUser: User, profile: OrganizationProfile | null): CollaborationItem[] {
  const membersText: string = profile === null ? '0 人' : `${profile.departmentMembers.length} 人`;
  const members: EmployeeDirectoryItem[] = profile === null ? [] : profile.departmentMembers;
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
      needsAction: false,
      participantIds: members.map((item: EmployeeDirectoryItem) => item.id),
      members
    }
  ];
}

function buildChainItems(currentUser: User, profile: OrganizationProfile | null): CollaborationItem[] {
  if (profile === null) {
    return [];
  }

  const items: CollaborationItem[] = [];
  if (profile.manager !== null) {
    const managerItem: CollaborationItem = {
      id: `chain-${[currentUser.id, profile.manager.id].sort().join('-')}`,
      kind: 'chain',
      title: '直属上级',
      summary: `${profile.manager.name} · ${profile.manager.jobTitle}`,
      ownerName: profile.manager.name,
      ownerDepartment: profile.manager.departmentName,
      timeText: '随时可联系',
      placeText: '组织关系',
      statusText: '可直联',
      state: 'active',
      needsAction: false,
      participantIds: [profile.manager.id],
      members: [profile.manager]
    };
    items.push(managerItem);
  }

  profile.directReports.forEach((item: EmployeeDirectoryItem, index: number) => {
    const chainItem: CollaborationItem = {
      id: `chain-${[currentUser.id, item.id].sort().join('-')}`,
      kind: 'chain',
      title: item.name,
      summary: `${item.jobTitle} · ${item.departmentName}`,
      ownerName: item.name,
      ownerDepartment: item.departmentName,
      timeText: '可协同',
      placeText: '直接下属',
      statusText: '可对接',
      state: 'active',
      needsAction: false,
      participantIds: [item.id],
      members: [item]
    };
    items.push(chainItem);
  });

  return items;
}

export function buildCollaborationBoardUseCase(
  currentUser: User | null,
  profile: OrganizationProfile | null,
  workflowInstances: WorkflowInstance[],
  customMeetingItems: CollaborationItem[] = [],
  confirmedMeetingIds: string[] = [],
  customTaskItems: CollaborationItem[] = [],
  acceptedTaskIds: string[] = []
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

  const meetingItems: CollaborationItem[] = customMeetingItems
    .concat(buildMeetingItems(currentUser, profile))
    .map((item: CollaborationItem) => {
      if (!confirmedMeetingIds.includes(item.id)) {
        return item;
      }
      return {
        id: item.id,
        kind: item.kind,
        title: item.title,
        summary: item.summary,
        ownerName: item.ownerName,
        ownerDepartment: item.ownerDepartment,
        timeText: item.timeText,
        placeText: item.placeText,
        statusText: '已确认',
        state: 'active',
        needsAction: false,
        participantIds: item.participantIds,
        members: item.members
      };
    });
  const taskItems: CollaborationItem[] = buildCustomTaskItems(currentUser, customTaskItems, acceptedTaskIds)
    .concat(buildTaskItems(currentUser, profile, workflowInstances))
    .map((item: CollaborationItem) => {
      if (!acceptedTaskIds.includes(item.id)) {
        return item;
      }
      return copyTaskWithStatus(item, '已同意', 'active', false);
    });
  const groupItems: CollaborationItem[] = buildGroupItems(currentUser, profile);
  const chainItems: CollaborationItem[] = buildChainItems(currentUser, profile);

  const actionWorkflowCount: number = countActionWorkflows(currentUser, workflowInstances);
  const waitingWorkflowCount: number = countMyPendingWorkflows(currentUser, workflowInstances);
  const actionCount: number = actionWorkflowCount
    + meetingItems.filter((item: CollaborationItem) => item.needsAction).length
    + taskItems.filter((item: CollaborationItem) => item.needsAction).length;
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
