import { buildCollaborationBoardUseCase } from '../../app/usecases/CollaborationUseCases';
import {
  loadCollaborationMessagesUseCase,
  sendCollaborationMessageUseCase
} from '../../app/usecases/CollaborationMessageUseCases';
import { findEmployeeByIdUseCase } from '../../app/usecases/OrganizationUseCases';
import { EmptyState } from '../../common/components/EmptyState';
import { SectionBlock } from '../../common/components/SectionBlock';
import { AppTheme } from '../../common/theme/AppTheme';
import { Typography } from '../../common/theme/Typography';
import {
  CollaborationBoard,
  CollaborationItem,
  CollaborationKind,
  CollaborationMessage,
  EmployeeDirectoryItem,
  OrganizationProfile,
  User,
  WorkflowInstance
} from '../../models/AppModels';

@Component
export struct CollaborationPage {
  @Require @Prop user: User;
  @Require @Prop profile: OrganizationProfile | null;
  @Require @Prop workflowInstances: WorkflowInstance[]; 
  @Prop focus: 'all' | 'action' | 'waiting' = 'all';
  @Require @Prop customMeetingItems: CollaborationItem[];
  @Require @Prop confirmedMeetingIds: string[];
  @Require @Prop customTaskItems: CollaborationItem[];
  @Require @Prop acceptedTaskIds: string[];
  onCreateMeeting: (item: CollaborationItem) => void = () => {};
  onConfirmMeeting: (meetingId: string) => void = () => {};
  onCreateTask: (item: CollaborationItem) => void = () => {};
  onAcceptTask: (taskId: string) => void = () => {};
  onCloseGroup: (memberIds: string[], groupTitle: string) => void = () => {};

  @State customGroups: CollaborationItem[] = [];
  @State managedGroups: CollaborationItem[] = [];
  @State locallyConfirmedMeetingIds: string[] = [];
  @State locallyAcceptedTaskIds: string[] = [];
  @State closedTasks: CollaborationItem[] = [];
  @State closedTaskIds: string[] = [];
  @State closedGroupIds: string[] = [];
  @State conversationMessages: CollaborationMessage[] = [];
  @State activeThreadId: string = '';
  @State activeThreadTitle: string = '';
  @State activeThreadSummary: string = '';
  @State activeThreadKind: CollaborationKind = 'task';
  @State conversationVisible: boolean = false;
  @State conversationInput: string = '';
  @State conversationLoading: boolean = false;
  @State activeReceiverIds: string[] = [];
  @State meetingDialogVisible: boolean = false;
  @State taskDialogVisible: boolean = false;
  @State groupDialogVisible: boolean = false;
  @State taskCloseConfirmVisible: boolean = false;
  @State pendingTaskToClose: CollaborationItem | null = null;
  @State pendingGroupToClose: CollaborationItem | null = null;
  @State meetingParticipantIdsInput: string = '';
  @State meetingTitleInput: string = '';
  @State meetingTimeInput: string = '';
  @State meetingPlaceInput: string = '';
  @State meetingSummaryInput: string = '';
  @State meetingRelationshipPickerVisible: boolean = false;
  @State taskTitleInput: string = '';
  @State taskParticipantIdsInput: string = '';
  @State taskTimeInput: string = '';
  @State taskSummaryInput: string = '';
  @State taskRelationshipPickerVisible: boolean = false;
  @State groupTitleInput: string = '';
  @State groupMemberIdsInput: string = '';
  @State groupSummaryInput: string = '';
  @State groupRelationshipPickerVisible: boolean = false;
  @State activeGroupMemberPickerId: string = '';
  @State groupMemberIdInput: string = '';
  @State collaborationModuleVisible: boolean = false;
  @State activeCollaborationModule: CollaborationKind = 'meeting';
  @State taskListView: 'active' | 'closed' = 'active';

  private getBoard(): CollaborationBoard {
    return buildCollaborationBoardUseCase(
      this.user,
      this.profile,
      this.workflowInstances,
      this.customMeetingItems,
      this.getConfirmedMeetingIds(),
      this.customTaskItems,
      this.getAcceptedTaskIds()
    );
  }

  private getConfirmedMeetingIds(): string[] {
    return this.confirmedMeetingIds.concat(this.locallyConfirmedMeetingIds);
  }

  private getAcceptedTaskIds(): string[] {
    return this.acceptedTaskIds.concat(this.locallyAcceptedTaskIds);
  }

  private getCombinedMeetingItems(): CollaborationItem[] {
    return this.getBoard().meetingItems;
  }

  private getCombinedTaskItems(): CollaborationItem[] {
    return this.getBoard().taskItems.filter((item: CollaborationItem) => !this.closedTaskIds.includes(item.id));
  }

  private getCombinedGroupItems(): CollaborationItem[] {
    const items: CollaborationItem[] = this.getBoard().groupItems.slice();
    this.customGroups.forEach((item: CollaborationItem) => items.unshift(item));
    return items
      .map((item: CollaborationItem) => this.getManagedGroup(item))
      .filter((item: CollaborationItem) => !this.closedGroupIds.includes(item.id));
  }

  private getManagedGroup(item: CollaborationItem): CollaborationItem {
    const managed: CollaborationItem | undefined = this.managedGroups.find(
      (group: CollaborationItem) => group.id === item.id
    );
    return managed === undefined ? item : managed;
  }

  private getCombinedChainItems(): CollaborationItem[] {
    return this.getBoard().chainItems;
  }

  private getVisibleMeetingItems(): CollaborationItem[] {
    const items: CollaborationItem[] = this.getCombinedMeetingItems();
    if (this.focus === 'action') {
      return items.filter((item: CollaborationItem) => item.needsAction);
    }
    if (this.focus === 'waiting') {
      return [];
    }
    return items;
  }

  private getVisibleTaskItems(): CollaborationItem[] {
    const items: CollaborationItem[] = this.getCombinedTaskItems();
    if (this.focus === 'action') {
      return items.filter((item: CollaborationItem) => item.needsAction);
    }
    if (this.focus === 'waiting') {
      return items.filter((item: CollaborationItem) => !item.needsAction);
    }
    return items;
  }

  private getClosedTaskItems(): CollaborationItem[] {
    return this.closedTasks;
  }

  private getRelatedEmployees(): EmployeeDirectoryItem[] {
    if (this.profile === null) {
      return [];
    }
    const employees: EmployeeDirectoryItem[] = [];
    if (this.profile.manager !== null) {
      employees.push(this.profile.manager);
    }
    this.profile.directReports.forEach((item: EmployeeDirectoryItem) => {
      if (!employees.some((employee: EmployeeDirectoryItem) => employee.id === item.id)) {
        employees.push(item);
      }
    });
    this.profile.departmentMembers.forEach((item: EmployeeDirectoryItem) => {
      if (item.id !== this.user.id && !employees.some((employee: EmployeeDirectoryItem) => employee.id === item.id)) {
        employees.push(item);
      }
    });
    return employees;
  }

  private getRelationshipLabel(employee: EmployeeDirectoryItem): string {
    if (this.profile !== null && this.profile.manager !== null && this.profile.manager.id === employee.id) {
      return '上级';
    }
    if (this.profile !== null && this.profile.directReports.some((item: EmployeeDirectoryItem) => item.id === employee.id)) {
      return '下级';
    }
    return '工作组 / 对接';
  }

  private getParticipantIds(value: string): string[] {
    return value
      .split(',')
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0);
  }

  private async resolveEmployeesById(employeeIds: string[]): Promise<EmployeeDirectoryItem[] | null> {
    const employees: EmployeeDirectoryItem[] = [];
    for (let index: number = 0; index < employeeIds.length; index += 1) {
      const employeeId: string = employeeIds[index];
      const employee: EmployeeDirectoryItem | null = await findEmployeeByIdUseCase(employeeId);
      if (employee === null) {
        this.showMessage(`未找到员工 ID：${employeeId}。`);
        return null;
      }
      if (employee.id === this.user.id) {
        this.showMessage('组长无需重复添加。');
        return null;
      }
      if (!employees.some((item: EmployeeDirectoryItem) => item.id === employee.id)) {
        employees.push(employee);
      }
    }
    return employees;
  }

  private addParticipant(employee: EmployeeDirectoryItem, target: 'meeting' | 'task' | 'group'): void {
    const input: string = target === 'meeting'
      ? this.meetingParticipantIdsInput
      : target === 'task' ? this.taskParticipantIdsInput : this.groupMemberIdsInput;
    const participantIds: string[] = this.getParticipantIds(input);
    if (!participantIds.includes(employee.id)) {
      participantIds.push(employee.id);
      if (target === 'meeting') {
        this.meetingParticipantIdsInput = participantIds.join(', ');
      } else if (target === 'task') {
        this.taskParticipantIdsInput = participantIds.join(', ');
      } else {
        this.groupMemberIdsInput = participantIds.join(', ');
      }
    }
  }

  private getVisibleGroupItems(): CollaborationItem[] {
    return this.focus === 'all' ? this.getCombinedGroupItems() : [];
  }

  private getVisibleChainItems(): CollaborationItem[] {
    return this.focus === 'all' ? this.getCombinedChainItems() : [];
  }

  private getActionCount(): number {
    return this.getBoard().actionCount;
  }

  private getWaitingCount(): number {
    return this.getBoard().waitingCount;
  }

  private getThreadId(item: CollaborationItem): string {
    return `${item.kind}:${item.id}`;
  }

  private getStatusTone(item: CollaborationItem): string {
    if (item.needsAction) {
      return '#B54708';
    }
    if (item.state === 'waiting') {
      return '#175CD3';
    }
    return '#027A48';
  }

  private getConversationItems(): CollaborationMessage[] {
    return this.conversationMessages.filter((item: CollaborationMessage) => item.threadId === this.activeThreadId);
  }

  private getItemMembers(item: CollaborationItem): EmployeeDirectoryItem[] {
    return item.members;
  }

  private getItemMemberSummary(item: CollaborationItem): string {
    const names: string[] = [];
    this.getItemMembers(item).forEach((member: EmployeeDirectoryItem) => {
      names.push(member.name);
    });
    return names.join('、');
  }

  private getReceiverIds(item: CollaborationItem): string[] {
    return item.participantIds.filter((id: string) => id !== this.user.id);
  }

  private getConversationPlaceholder(): string {
    if (this.activeThreadKind === 'chain') {
      return '输入工作汇报内容';
    }
    if (this.activeThreadKind === 'group') {
      return '输入工作组沟通内容';
    }
    return '输入对接消息';
  }

  private formatCurrentTime(): string {
    const now: Date = new Date();
    const month: string = now.getMonth() + 1 < 10 ? `0${now.getMonth() + 1}` : `${now.getMonth() + 1}`;
    const day: string = now.getDate() < 10 ? `0${now.getDate()}` : `${now.getDate()}`;
    const hour: string = now.getHours() < 10 ? `0${now.getHours()}` : `${now.getHours()}`;
    const minute: string = now.getMinutes() < 10 ? `0${now.getMinutes()}` : `${now.getMinutes()}`;
    return `${month}-${day} ${hour}:${minute}`;
  }

  private createId(prefix: string): string {
    return `${prefix}-${new Date().getTime()}`;
  }

  private padDateTimePart(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private parseMeetingDateTime(value: string): Date {
    const parsed: Date = new Date(value.trim().replace(' ', 'T'));
    return Number.isNaN(parsed.getTime()) ? new Date() : parsed;
  }

  private formatMeetingDateTime(value: Date): string {
    return `${value.getFullYear()}-${this.padDateTimePart(value.getMonth() + 1)}-${this.padDateTimePart(value.getDate())} ` +
      `${this.padDateTimePart(value.getHours())}:${this.padDateTimePart(value.getMinutes())}`;
  }

  private selectMeetingDateTime(): void {
    const selected: Date = this.parseMeetingDateTime(this.meetingTimeInput);
    this.getUIContext().showDatePickerDialog({
      selected,
      onAccept: (dateResult: DatePickerResult) => {
        const selectedDate: Date = new Date(selected.getTime());
        const year: number = dateResult.year === undefined ? selected.getFullYear() : dateResult.year;
        const month: number = dateResult.month === undefined ? selected.getMonth() : dateResult.month;
        const day: number = dateResult.day === undefined ? selected.getDate() : dateResult.day;
        selectedDate.setFullYear(year, month, day);
        this.getUIContext().showTimePickerDialog({
          selected: selectedDate,
          useMilitaryTime: true,
          onAccept: (timeResult: TimePickerResult) => {
            selectedDate.setHours(timeResult.hour, timeResult.minute, 0, 0);
            this.meetingTimeInput = this.formatMeetingDateTime(selectedDate);
          }
        });
      }
    });
  }

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (error) {
      console.error(`CollaborationPage toast failed: ${error}`);
    }
  }

  private async openConversation(item: CollaborationItem): Promise<void> {
    this.activeThreadId = this.getThreadId(item);
    this.activeThreadTitle = item.title;
    this.activeThreadSummary = `${item.ownerName} · ${item.ownerDepartment}`;
    this.activeThreadKind = item.kind;
    this.activeReceiverIds = this.getReceiverIds(item);
    this.conversationInput = '';
    this.conversationVisible = true;
    this.conversationLoading = true;
    try {
      this.conversationMessages = await loadCollaborationMessagesUseCase(this.activeThreadId);
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '会话消息加载失败。';
      this.showMessage(message);
    } finally {
      this.conversationLoading = false;
    }
  }

  private async sendConversationMessage(): Promise<void> {
    const content: string = this.conversationInput.trim();
    if (content.length === 0 || this.activeThreadId.length === 0) {
      this.showMessage('请先输入要发送的文本。');
      return;
    }

    if (this.activeReceiverIds.length === 0) {
      this.showMessage('当前协作事项没有可投递成员，请选择工作组成员或填写成员姓名、账号。');
      return;
    }
    try {
      const message: CollaborationMessage = await sendCollaborationMessageUseCase(
        this.activeThreadId,
        this.activeReceiverIds,
        content
      );
      this.conversationMessages = this.conversationMessages.concat([message]);
      this.conversationInput = '';
      this.showMessage('消息已发送到接收成员账户。');
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '消息发送失败。';
      this.showMessage(message);
    }
  }

  private openMeetingDialog(): void {
    this.meetingParticipantIdsInput = '';
    this.meetingTitleInput = '';
    this.meetingTimeInput = '';
    this.meetingPlaceInput = '';
    this.meetingSummaryInput = '';
    this.meetingRelationshipPickerVisible = false;
    this.meetingDialogVisible = true;
  }

  private createMeeting(): void {
    const employeeIds: string[] = this.getParticipantIds(this.meetingParticipantIdsInput);
    const title: string = this.meetingTitleInput.trim();
    const timeText: string = this.meetingTimeInput.trim();
    const placeText: string = this.meetingPlaceInput.trim();
    const summary: string = this.meetingSummaryInput.trim();
    const participants: EmployeeDirectoryItem[] = this.getRelatedEmployees().filter(
      (item: EmployeeDirectoryItem) => employeeIds.includes(item.id)
    );
    if (title.length === 0 || timeText.length === 0 || placeText.length === 0 || employeeIds.length === 0) {
      this.showMessage('请填写参会员工 ID、会议标题、时间和地点。');
      return;
    }

    const item: CollaborationItem = {
      id: this.createId('meeting'),
      kind: 'meeting',
      title,
      summary: summary.length > 0 ? summary : `已邀请 ${employeeIds.length} 位员工待确认。`,
      ownerName: this.user.name,
      ownerDepartment: this.user.department,
      timeText,
      placeText,
      statusText: '待确认',
      state: 'action',
      needsAction: true,
      participantIds: employeeIds,
      members: participants
    };
    this.meetingDialogVisible = false;
    this.onCreateMeeting(item);
    this.showMessage('已新建会议并发送待确认通知。');
  }

  private confirmMeeting(item: CollaborationItem): void {
    if (this.getConfirmedMeetingIds().includes(item.id)) {
      return;
    }
    this.locallyConfirmedMeetingIds = this.locallyConfirmedMeetingIds.concat([item.id]);
    this.onConfirmMeeting(item.id);
    this.showMessage('已确认参会安排。');
  }

  private openTaskDialog(): void {
    this.taskTitleInput = '';
    this.taskParticipantIdsInput = '';
    this.taskTimeInput = '';
    this.taskSummaryInput = '';
    this.taskRelationshipPickerVisible = false;
    this.taskDialogVisible = true;
  }

  private openGroupDialog(): void {
    this.groupTitleInput = '';
    this.groupMemberIdsInput = '';
    this.groupSummaryInput = '';
    this.groupRelationshipPickerVisible = false;
    this.groupDialogVisible = true;
  }

  private createTask(): void {
    const title: string = this.taskTitleInput.trim();
    const participantIds: string[] = this.getParticipantIds(this.taskParticipantIdsInput);
    const timeText: string = this.taskTimeInput.trim();
    const summary: string = this.taskSummaryInput.trim();
    const targetMembers: EmployeeDirectoryItem[] = this.getRelatedEmployees().filter(
      (item: EmployeeDirectoryItem) => participantIds.includes(item.id)
    );
    if (title.length === 0 || participantIds.length === 0 || timeText.length === 0) {
      this.showMessage('请填写对接标题、关联人员和时间。');
      return;
    }

    const item: CollaborationItem = {
      id: this.createId('task'),
      kind: 'task',
      title,
      summary: summary.length > 0 ? summary : `对接人员：${targetMembers.map((item: EmployeeDirectoryItem) => item.name).join('、')}`,
      ownerName: this.user.name,
      ownerDepartment: this.user.department,
      timeText,
      placeText: '工作对接',
      statusText: '等待同意',
      state: 'waiting',
      needsAction: false,
      participantIds,
      members: targetMembers
    };
    this.taskDialogVisible = false;
    this.onCreateTask(item);
    this.showMessage('已新建工作对接。');
  }

  private acceptTask(item: CollaborationItem): void {
    if (this.getAcceptedTaskIds().includes(item.id)) {
      return;
    }
    this.locallyAcceptedTaskIds = this.locallyAcceptedTaskIds.concat([item.id]);
    this.onAcceptTask(item.id);
    this.showMessage('已同意工作对接。');
  }

  private async createGroup(): Promise<void> {
    const title: string = this.groupTitleInput.trim();
    const selectedMemberIds: string[] = this.getParticipantIds(this.groupMemberIdsInput);
    const summary: string = this.groupSummaryInput.trim();
    if (title.length === 0 || selectedMemberIds.length === 0) {
      this.showMessage('请填写工作组名称并选择至少一位组员。');
      return;
    }
    const selectedMembers: EmployeeDirectoryItem[] | null = await this.resolveEmployeesById(selectedMemberIds);
    if (selectedMembers === null) {
      return;
    }
    const owner: EmployeeDirectoryItem = {
      id: this.user.id,
      name: this.user.name,
      account: this.user.account,
      departmentId: this.user.departmentId,
      departmentName: this.user.department,
      jobTitle: this.user.jobTitle,
      managerId: this.user.managerId,
      managerName: '',
      employmentStatus: this.user.employmentStatus
    };
    const members: EmployeeDirectoryItem[] = [owner].concat(selectedMembers);
    const item: CollaborationItem = {
      id: this.createId('group'),
      kind: 'group',
      title,
      summary: summary.length > 0 ? summary : `由 ${this.user.name} 创建的工作组`,
      ownerName: this.user.name,
      ownerDepartment: this.user.department,
      timeText: '长期协作',
      placeText: '协作页',
      statusText: '活跃',
      state: 'active',
      needsAction: false,
      participantIds: [this.user.id].concat(selectedMembers.map((member: EmployeeDirectoryItem) => member.id)),
      members
    };
    const nextGroups: CollaborationItem[] = this.customGroups.slice();
    nextGroups.unshift(item);
    this.customGroups = nextGroups;
    this.groupDialogVisible = false;
    this.showMessage('已新建工作组。');
  }

  private requestTaskClose(item: CollaborationItem): void {
    this.pendingTaskToClose = item;
    this.taskCloseConfirmVisible = true;
  }

  private confirmTaskClose(): void {
    if (this.pendingTaskToClose !== null) {
      this.closeTask(this.pendingTaskToClose);
    }
    if (this.pendingGroupToClose !== null) {
      this.closeGroup(this.pendingGroupToClose);
    }
    this.pendingTaskToClose = null;
    this.pendingGroupToClose = null;
    this.taskCloseConfirmVisible = false;
  }

  private cancelTaskClose(): void {
    this.pendingTaskToClose = null;
    this.pendingGroupToClose = null;
    this.taskCloseConfirmVisible = false;
  }

  private closeTask(item: CollaborationItem): void {
    if (this.closedTaskIds.includes(item.id)) {
      return;
    }
    this.closedTaskIds = this.closedTaskIds.concat([item.id]);
    const closedItem: CollaborationItem = {
      id: item.id,
      kind: item.kind,
      title: item.title,
      summary: `${item.summary}（已由 ${this.user.name} 关闭）`,
      ownerName: item.ownerName,
      ownerDepartment: item.ownerDepartment,
      timeText: item.timeText,
      placeText: item.placeText,
      statusText: '已完成',
      state: 'active',
      needsAction: false,
      participantIds: item.participantIds,
      members: item.members
    };
    const nextClosedTasks: CollaborationItem[] = this.closedTasks.slice();
    nextClosedTasks.unshift(closedItem);
    this.closedTasks = nextClosedTasks;
    this.showMessage('工作对接已完成。');
  }

  private isGroupLeader(item: CollaborationItem): boolean {
    return item.kind === 'group' && item.ownerName === this.user.name;
  }

  private getAvailableGroupMembers(item: CollaborationItem): EmployeeDirectoryItem[] {
    return this.getRelatedEmployees().filter((employee: EmployeeDirectoryItem) => {
      return !item.participantIds.includes(employee.id);
    });
  }

  private updateManagedGroup(item: CollaborationItem, members: EmployeeDirectoryItem[]): void {
    const participantIds: string[] = members.map((member: EmployeeDirectoryItem) => member.id);
    if (!participantIds.includes(this.user.id)) {
      participantIds.unshift(this.user.id);
    }
    const updated: CollaborationItem = {
      id: item.id,
      kind: item.kind,
      title: item.title,
      summary: item.summary,
      ownerName: item.ownerName,
      ownerDepartment: item.ownerDepartment,
      timeText: item.timeText,
      placeText: item.placeText,
      statusText: item.statusText,
      state: item.state,
      needsAction: item.needsAction,
      participantIds,
      members
    };
    const nextGroups: CollaborationItem[] = this.managedGroups.filter((group: CollaborationItem) => group.id !== item.id);
    nextGroups.push(updated);
    this.managedGroups = nextGroups;
  }

  private addGroupMember(item: CollaborationItem, member: EmployeeDirectoryItem): void {
    if (!this.isGroupLeader(item) || item.participantIds.includes(member.id)) {
      return;
    }
    const members: EmployeeDirectoryItem[] = item.members.slice();
    members.push(member);
    this.updateManagedGroup(item, members);
    this.showMessage(`已将 ${member.name} 加入工作组。`);
  }

  private removeGroupMember(item: CollaborationItem, member: EmployeeDirectoryItem): void {
    if (!this.isGroupLeader(item) || member.id === this.user.id) {
      return;
    }
    const members: EmployeeDirectoryItem[] = item.members.filter(
      (groupMember: EmployeeDirectoryItem) => groupMember.id !== member.id
    );
    this.updateManagedGroup(item, members);
    this.showMessage(`已将 ${member.name} 移出工作组。`);
  }

  private toggleGroupMemberPicker(item: CollaborationItem): void {
    this.activeGroupMemberPickerId = this.activeGroupMemberPickerId === item.id ? '' : item.id;
    this.groupMemberIdInput = '';
  }

  private async addGroupMemberById(item: CollaborationItem): Promise<void> {
    const employeeId: string = this.groupMemberIdInput.trim();
    if (employeeId.length === 0) {
      this.showMessage('请输入员工 ID。');
      return;
    }
    try {
      const employees: EmployeeDirectoryItem[] | null = await this.resolveEmployeesById([employeeId]);
      if (employees === null || employees.length === 0) {
        return;
      }
      const employee: EmployeeDirectoryItem = employees[0];
      if (employee.id === this.user.id) {
        this.showMessage('组长已在工作组中。');
        return;
      }
      this.addGroupMember(item, employee);
      this.groupMemberIdInput = '';
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '员工查询失败。';
      this.showMessage(message);
    }
  }

  private requestGroupClose(item: CollaborationItem): void {
    if (!this.isGroupLeader(item)) {
      return;
    }
    this.pendingGroupToClose = item;
    this.taskCloseConfirmVisible = true;
  }

  private getPendingCloseItem(): CollaborationItem | null {
    return this.pendingTaskToClose === null ? this.pendingGroupToClose : this.pendingTaskToClose;
  }

  private getCloseConfirmTitle(): string {
    return this.pendingGroupToClose === null ? '确认完成对接' : '确认关闭工作组';
  }

  private getCloseConfirmDescription(): string {
    const item: CollaborationItem | null = this.getPendingCloseItem();
    if (item === null) {
      return '';
    }
    return this.pendingGroupToClose === null
      ? `完成“${item.title}”后，对接将移入“完成的对接”。`
      : `关闭“${item.title}”后，组员将收到关闭通知，且无法继续在该工作组协作。`;
  }

  private closeGroup(item: CollaborationItem): void {
    if (!this.isGroupLeader(item)) {
      return;
    }
    this.closedGroupIds = this.closedGroupIds.concat([item.id]);
    const memberIds: string[] = item.participantIds.filter((id: string) => id !== this.user.id);
    this.onCloseGroup(memberIds, item.title);
    this.showMessage(memberIds.length > 0 ? '工作组已关闭，已通知组员。' : '工作组已关闭。');
  }

  @Builder
  private StatCard(label: string, value: number, tone: string) {
    Column({ space: 3 }) {
      Text(`${value}`)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(tone)
        .maxLines(1)
      Text(label)
        .fontSize(Typography.captionSize())
        .fontColor(AppTheme.textSecondary())
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private ConversationMessageItem(message: CollaborationMessage) {
    Column({ space: 4 }) {
      Row({ space: 6 }) {
        Text(message.senderName)
          .fontSize(Typography.metaSize())
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.textPrimary())
          .maxLines(1)
        Text(message.senderRoleLabel)
          .fontSize(Typography.captionSize())
          .fontColor(AppTheme.textSecondary())
          .maxLines(1)
        Blank()
        Text(message.timeText)
          .fontSize(Typography.microSize())
          .fontColor(AppTheme.textTertiary())
      }
      .width('100%')

      Text(message.content)
        .fontSize(Typography.bodySize())
        .fontColor(AppTheme.textPrimary())
        .lineHeight(Typography.bodyLineHeight())
        .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(AppTheme.surfaceMuted())
    .borderRadius(AppTheme.radiusSmall())
  }

  @Builder
  private CollaborationCard(item: CollaborationItem) {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Column({ space: 3 }) {
          Text(item.title)
            .fontSize(Typography.bodySize())
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.textPrimary())
            .width('100%')
            .maxLines(1)
          Text(item.summary)
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.textSecondary())
            .lineHeight(Typography.summaryLineHeight())
            .width('100%')
            .maxLines(2)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(item.statusText)
          .fontSize(11)
          .fontColor(this.getStatusTone(item))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(item.needsAction ? '#FEF0C7' : item.state === 'waiting' ? '#EAF1FF' : '#ECFDF3')
          .borderRadius(AppTheme.radiusSmall())
      }
      .width('100%')

      Row({ space: 10 }) {
        Column({ space: 2 }) {
          Text(item.timeText)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textPrimary())
            .maxLines(1)
          Text(item.placeText)
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.textSecondary())
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 2 }) {
          Text(item.ownerName)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textPrimary())
            .maxLines(1)
          Text(item.ownerDepartment)
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.textSecondary())
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      if (item.kind === 'group') {
        Column({ space: 6 }) {
          Text(`组长：${item.ownerName}`)
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.primary())
            .width('100%')
          Text(`成员 (${this.getItemMembers(item).length})`)
            .fontSize(Typography.metaSize())
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.textPrimary())
            .width('100%')
          Text(this.getItemMemberSummary(item))
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.textSecondary())
            .lineHeight(Typography.summaryLineHeight())
            .width('100%')
            .maxLines(3)
          ForEach(this.getItemMembers(item), (member: EmployeeDirectoryItem) => {
            Row({ space: 8 }) {
              Text(member.name.slice(0, 1))
                .fontSize(Typography.captionSize())
                .fontColor(AppTheme.primary())
                .width(24)
                .height(24)
                .textAlign(TextAlign.Center)
                .padding({ top: 4 })
                .backgroundColor(AppTheme.primarySoft())
                .borderRadius(12)
              Text(member.name)
                .fontSize(Typography.metaSize())
                .fontColor(AppTheme.textPrimary())
                .layoutWeight(1)
                .maxLines(1)
              Text(member.id === this.user.id ? '本人' : member.jobTitle)
                .fontSize(Typography.captionSize())
                .fontColor(AppTheme.textSecondary())
                .maxLines(1)
              if (this.isGroupLeader(item) && member.id !== this.user.id) {
                Button('移除')
                  .height(28)
                  .fontSize(Typography.captionSize())
                  .fontColor('#B42318')
                  .backgroundColor('#FEF3F2')
                  .borderRadius(AppTheme.radiusSmall())
                  .onClick(() => {
                    this.removeGroupMember(item, member);
                  })
              }
            }
            .width('100%')
          }, (member: EmployeeDirectoryItem) => member.id)
        }
        .width('100%')
        .padding(10)
        .backgroundColor(AppTheme.surfaceMuted())
        .borderRadius(AppTheme.radiusSmall())

        if (this.isGroupLeader(item)) {
          Button(this.activeGroupMemberPickerId === item.id ? '收起成员管理' : '添加成员')
            .width('100%')
            .height(36)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.primary())
            .backgroundColor(AppTheme.primarySoft())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.toggleGroupMemberPicker(item);
            })

          if (this.activeGroupMemberPickerId === item.id) {
            Column({ space: 8 }) {
              Row({ space: 8 }) {
                TextInput({ placeholder: '输入其他员工 ID', text: this.groupMemberIdInput })
                  .layoutWeight(1)
                  .height(38)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(AppTheme.radiusSmall())
                  .padding({ left: 12, right: 12 })
                  .onChange((value: string) => {
                    this.groupMemberIdInput = value;
                  })
                Button('按 ID 添加')
                  .height(38)
                  .fontSize(Typography.captionSize())
                  .fontColor('#FFFFFF')
                  .backgroundColor(AppTheme.primary())
                  .borderRadius(AppTheme.radiusSmall())
                  .onClick(() => {
                    void this.addGroupMemberById(item);
                  })
              }
              .width('100%')

              if (this.getAvailableGroupMembers(item).length === 0) {
                Text('暂无可添加的关联人员。')
                  .fontSize(Typography.captionSize())
                  .fontColor(AppTheme.textSecondary())
                  .width('100%')
              } else {
                ForEach(this.getAvailableGroupMembers(item), (employee: EmployeeDirectoryItem) => {
                  Row() {
                    Column({ space: 2 }) {
                      Text(`${employee.name} · ${employee.jobTitle}`)
                        .fontSize(Typography.metaSize())
                        .fontColor(AppTheme.textPrimary())
                        .maxLines(1)
                      Text(`${this.getRelationshipLabel(employee)} · ${employee.departmentName}`)
                        .fontSize(Typography.captionSize())
                        .fontColor(AppTheme.textSecondary())
                        .maxLines(1)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Button('添加')
                      .height(30)
                      .fontSize(Typography.captionSize())
                      .fontColor(AppTheme.primary())
                      .backgroundColor('#FFFFFF')
                      .borderRadius(AppTheme.radiusSmall())
                      .onClick(() => {
                        this.addGroupMember(item, employee);
                      })
                  }
                  .width('100%')
                  .padding({ top: 6, bottom: 6 })
                  .border({ width: { bottom: 1 }, color: AppTheme.divider() })
                }, (employee: EmployeeDirectoryItem) => employee.id)
              }
            }
            .width('100%')
            .padding(10)
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
          }
        }
      }

      if (item.kind === 'meeting' && item.needsAction) {
        Button('确认会议')
          .width('100%')
          .height(36)
          .fontSize(Typography.metaSize())
          .fontColor('#FFFFFF')
          .backgroundColor(AppTheme.primary())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.confirmMeeting(item);
        })
      }

      if (item.kind === 'task' && item.needsAction) {
        Button('同意对接')
          .width('100%')
          .height(36)
          .fontSize(Typography.metaSize())
          .fontColor('#FFFFFF')
          .backgroundColor(AppTheme.primary())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.acceptTask(item);
          })
      }

      if (item.kind === 'task' && item.state === 'active' && !this.closedTaskIds.includes(item.id)) {
        Button('完成对接')
          .width('100%')
          .height(36)
          .fontSize(Typography.metaSize())
          .fontColor('#B42318')
          .backgroundColor('#FEF3F2')
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.requestTaskClose(item);
          })
      }

      if (this.isGroupLeader(item)) {
        Button('关闭工作组')
          .width('100%')
          .height(36)
          .fontSize(Typography.metaSize())
          .fontColor('#B42318')
          .backgroundColor('#FEF3F2')
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.requestGroupClose(item);
          })
      }

    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppTheme.surface())
    .borderRadius(AppTheme.radiusSmall())
    .border({ width: 1, color: AppTheme.divider() })
    .onClick(() => {
      if (item.kind !== 'meeting') {
        void this.openConversation(item);
      }
    })
  }

  @Builder
  private ConversationDialog() {
    Column() {
      Column({ space: 12 }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.activeThreadTitle)
              .fontSize(Typography.sectionTitleSize())
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.textPrimary())
              .maxLines(1)
            Text(this.activeThreadSummary)
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
              .maxLines(1)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('关闭')
            .height(32)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textSecondary())
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.conversationVisible = false;
            })
        }
        .width('100%')

        Scroll() {
          if (this.conversationLoading) {
            Text('正在加载会话…')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 24 })
          } else if (this.getConversationItems().length === 0) {
            EmptyState({
              title: '暂无文本消息',
              description: '先输入一段内容，就会在这里开始会话。'
            })
          } else {
            Column({ space: 8 }) {
              ForEach(this.getConversationItems(), (item: CollaborationMessage) => {
                this.ConversationMessageItem(item);
              }, (item: CollaborationMessage) => item.id)
            }
            .width('100%')
          }
        }
        .height(300)
        .scrollBar(BarState.Off)

        Column({ space: 8 }) {
          TextInput({ placeholder: this.getConversationPlaceholder(), text: this.conversationInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.conversationInput = value;
            })

          Button('发送')
            .width('100%')
            .height(40)
            .fontColor('#FFFFFF')
            .backgroundColor(AppTheme.primary())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              void this.sendConversationMessage();
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  @Builder
  private MeetingDialog() {
    Column() {
      Column({ space: 12 }) {
        Row() {
          Column({ space: 4 }) {
            Text('新建会议信息')
              .fontSize(Typography.sectionTitleSize())
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.textPrimary())
            Text('填写会议信息后，会出现在会议列表中。')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('关闭')
            .height(32)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textSecondary())
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.meetingDialogVisible = false;
            })
        }

        Column({ space: 10 }) {
          Row() {
            Text('参会人员')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
            Blank()
            Text('从关联人员选择')
              .fontSize(Typography.metaSize())
              .fontColor(AppTheme.primary())
              .onClick(() => {
                this.meetingRelationshipPickerVisible = !this.meetingRelationshipPickerVisible;
              })
          }
          .width('100%')

          TextInput({ placeholder: '参会员工 ID，多个用英文逗号分隔', text: this.meetingParticipantIdsInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.meetingParticipantIdsInput = value;
            })

          if (this.meetingRelationshipPickerVisible) {
            if (this.getRelatedEmployees().length === 0) {
              Text('暂无可选的关联人员。')
                .fontSize(Typography.captionSize())
                .fontColor(AppTheme.textSecondary())
            } else {
              ForEach(this.getRelatedEmployees(), (item: EmployeeDirectoryItem) => {
                Row() {
                  Column({ space: 2 }) {
                    Text(`${item.name} · ${item.jobTitle}`)
                      .fontSize(Typography.metaSize())
                      .fontColor(AppTheme.textPrimary())
                      .maxLines(1)
                    Text(`${this.getRelationshipLabel(item)} · ${item.departmentName} · ${item.id}`)
                      .fontSize(Typography.captionSize())
                      .fontColor(AppTheme.textSecondary())
                      .maxLines(1)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Button('添加')
                    .height(30)
                    .fontSize(Typography.captionSize())
                    .fontColor(AppTheme.primary())
                    .backgroundColor(AppTheme.primarySoft())
                    .borderRadius(AppTheme.radiusSmall())
                    .onClick(() => {
                      this.addParticipant(item, 'meeting');
                    })
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .border({ width: { bottom: 1 }, color: AppTheme.divider() })
              }, (item: EmployeeDirectoryItem) => item.id)
            }
          }

          TextInput({ placeholder: '会议标题', text: this.meetingTitleInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.meetingTitleInput = value;
            })

          Column({ space: 6 }) {
            Text('会议时间')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
            Row() {
              Text(this.meetingTimeInput.length > 0 ? this.meetingTimeInput : '请选择日期和时间')
                .fontSize(Typography.metaSize())
                .fontColor(this.meetingTimeInput.length > 0 ? AppTheme.textPrimary() : AppTheme.textTertiary())
                .layoutWeight(1)
              Text('选择')
                .fontSize(Typography.metaSize())
                .fontColor(AppTheme.primary())
            }
            .width('100%')
            .height(44)
            .padding({ left: 14, right: 14 })
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.selectMeetingDateTime();
            })
          }
          .width('100%')

          TextInput({ placeholder: '会议地点，例如：A 栋 3 层会议室', text: this.meetingPlaceInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.meetingPlaceInput = value;
            })

          TextInput({ placeholder: '会议说明，可选', text: this.meetingSummaryInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.meetingSummaryInput = value;
            })
        }
        .width('100%')

        Button('保存会议')
          .width('100%')
          .height(42)
          .fontColor('#FFFFFF')
          .backgroundColor(AppTheme.primary())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.createMeeting();
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  @Builder
  private CollaborationModuleCard(kind: CollaborationKind, title: string, subtitle: string, count: number) {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Typography.sectionTitleSize())
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.textPrimary())
        Text(subtitle)
          .fontSize(Typography.captionSize())
          .fontColor(AppTheme.textSecondary())
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(`${count}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.primary())
      Text('›')
        .fontSize(22)
        .fontColor(AppTheme.textTertiary())
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppTheme.surface())
    .border({ width: 1, color: AppTheme.divider() })
    .borderRadius(AppTheme.radiusSmall())
    .onClick(() => {
      this.activeCollaborationModule = kind;
      if (kind === 'task') {
        this.taskListView = 'active';
      }
      this.collaborationModuleVisible = true;
    })
  }

  private getActiveCollaborationItems(): CollaborationItem[] {
    if (this.activeCollaborationModule === 'meeting') {
      return this.getVisibleMeetingItems();
    }
    if (this.activeCollaborationModule === 'task') {
      return this.taskListView === 'closed' ? this.getClosedTaskItems() : this.getVisibleTaskItems();
    }
    if (this.activeCollaborationModule === 'group') {
      return this.getCombinedGroupItems();
    }
    return this.getCombinedChainItems();
  }

  private getActiveCollaborationTitle(): string {
    if (this.activeCollaborationModule === 'meeting') {
      return '会议信息';
    }
    if (this.activeCollaborationModule === 'task') {
      return '工作对接';
    }
    if (this.activeCollaborationModule === 'group') {
      return '工作组';
    }
    return '工作汇报';
  }

  @Builder
  private CollaborationModuleDialog() {
    Column() {
      Column({ space: 14 }) {
        Row() {
          Text(this.getActiveCollaborationTitle())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.textPrimary())
            .layoutWeight(1)
          Button('关闭')
            .height(34)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textSecondary())
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.collaborationModuleVisible = false;
            })
        }
        .width('100%')

        if (this.activeCollaborationModule === 'task') {
          Row({ space: 8 }) {
            Button('进行中')
              .layoutWeight(1)
              .height(34)
              .fontSize(Typography.metaSize())
              .fontColor(this.taskListView === 'active' ? '#FFFFFF' : AppTheme.textSecondary())
              .backgroundColor(this.taskListView === 'active' ? AppTheme.primary() : AppTheme.surfaceMuted())
              .borderRadius(AppTheme.radiusSmall())
              .onClick(() => {
                this.taskListView = 'active';
              })
            Button(`完成的对接 ${this.getClosedTaskItems().length}`)
              .layoutWeight(1)
              .height(34)
              .fontSize(Typography.metaSize())
              .fontColor(this.taskListView === 'closed' ? '#FFFFFF' : AppTheme.textSecondary())
              .backgroundColor(this.taskListView === 'closed' ? AppTheme.primary() : AppTheme.surfaceMuted())
              .borderRadius(AppTheme.radiusSmall())
              .onClick(() => {
                this.taskListView = 'closed';
              })
          }
          .width('100%')
        }

        Scroll() {
          if (this.getActiveCollaborationItems().length === 0) {
            EmptyState({ title: '暂无内容', description: '当前模块还没有可展示的协作事项。' })
          } else {
            Column({ space: 10 }) {
              ForEach(this.getActiveCollaborationItems(), (item: CollaborationItem) => {
                this.CollaborationCard(item);
              }, (item: CollaborationItem) => item.id)
            }
            .width('100%')
          }
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
      .height('82%')
      .padding(18)
      .backgroundColor(AppTheme.surface())
      .borderRadius(AppTheme.radiusMedium())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  @Builder
  private TaskDialog() {
    Column() {
      Column({ space: 12 }) {
        Row() {
          Column({ space: 4 }) {
            Text('新建工作对接')
              .fontSize(Typography.sectionTitleSize())
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.textPrimary())
            Text('创建短期工作对接，随后可以直接进入文本通讯。')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('关闭')
            .height(32)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textSecondary())
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.taskDialogVisible = false;
            })
        }

        Column({ space: 10 }) {
          TextInput({ placeholder: '对接标题', text: this.taskTitleInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.taskTitleInput = value;
            })

          Row() {
            Text('关联人员')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
            Blank()
            Text('从关联人员选择')
              .fontSize(Typography.metaSize())
              .fontColor(AppTheme.primary())
              .onClick(() => {
                this.taskRelationshipPickerVisible = !this.taskRelationshipPickerVisible;
              })
          }
          .width('100%')

          TextInput({ placeholder: '关联人员 ID，多个用英文逗号分隔', text: this.taskParticipantIdsInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.taskParticipantIdsInput = value;
            })

          if (this.taskRelationshipPickerVisible) {
            if (this.getRelatedEmployees().length === 0) {
              Text('暂无可选的关联人员。')
                .fontSize(Typography.captionSize())
                .fontColor(AppTheme.textSecondary())
            } else {
              ForEach(this.getRelatedEmployees(), (item: EmployeeDirectoryItem) => {
                Row() {
                  Column({ space: 2 }) {
                    Text(`${item.name} · ${item.jobTitle}`)
                      .fontSize(Typography.metaSize())
                      .fontColor(AppTheme.textPrimary())
                      .maxLines(1)
                    Text(`${this.getRelationshipLabel(item)} · ${item.departmentName} · ${item.id}`)
                      .fontSize(Typography.captionSize())
                      .fontColor(AppTheme.textSecondary())
                      .maxLines(1)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Button('添加')
                    .height(30)
                    .fontSize(Typography.captionSize())
                    .fontColor(AppTheme.primary())
                    .backgroundColor(AppTheme.primarySoft())
                    .borderRadius(AppTheme.radiusSmall())
                    .onClick(() => {
                      this.addParticipant(item, 'task');
                    })
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .border({ width: { bottom: 1 }, color: AppTheme.divider() })
              }, (item: EmployeeDirectoryItem) => item.id)
            }
          }

          TextInput({ placeholder: '计划时间，例如：今天 18:00 前', text: this.taskTimeInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.taskTimeInput = value;
            })

          TextInput({ placeholder: '对接说明，可选', text: this.taskSummaryInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.taskSummaryInput = value;
            })
        }
        .width('100%')

        Button('保存对接')
          .width('100%')
          .height(42)
          .fontColor('#FFFFFF')
          .backgroundColor(AppTheme.primary())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.createTask();
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  @Builder
  private TaskCloseConfirmDialog() {
    Column() {
      Column({ space: 14 }) {
        Text(this.getCloseConfirmTitle())
          .fontSize(Typography.sectionTitleSize())
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.textPrimary())
          .width('100%')
        Text(this.getCloseConfirmDescription())
          .fontSize(Typography.bodySize())
          .fontColor(AppTheme.textSecondary())
          .lineHeight(Typography.bodyLineHeight())
          .width('100%')
        Row({ space: 10 }) {
          Button('取消')
            .layoutWeight(1)
            .height(40)
            .fontColor(AppTheme.textSecondary())
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.cancelTaskClose();
            })
          Button(this.pendingGroupToClose === null ? '确认完成' : '确认关闭')
            .layoutWeight(1)
            .height(40)
            .fontColor('#FFFFFF')
            .backgroundColor('#B42318')
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.confirmTaskClose();
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(AppTheme.radiusMedium())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  @Builder
  private GroupDialog() {
    Column() {
      Column({ space: 12 }) {
        Row() {
          Column({ space: 4 }) {
            Text('新建工作组')
              .fontSize(Typography.sectionTitleSize())
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.textPrimary())
            Text('选择组员后建立长期协作空间。')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Button('关闭')
            .height(32)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textSecondary())
            .backgroundColor(AppTheme.surfaceMuted())
            .borderRadius(AppTheme.radiusSmall())
            .onClick(() => {
              this.groupDialogVisible = false;
            })
        }
        .width('100%')

        Column({ space: 10 }) {
          TextInput({ placeholder: '工作组名称', text: this.groupTitleInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.groupTitleInput = value;
            })

          Row() {
            Text('组员')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.textSecondary())
            Blank()
            Text('从关联人员选择')
              .fontSize(Typography.metaSize())
              .fontColor(AppTheme.primary())
              .onClick(() => {
                this.groupRelationshipPickerVisible = !this.groupRelationshipPickerVisible;
              })
          }
          .width('100%')

          TextInput({ placeholder: '组员 ID，可输入跨部门员工，多个用英文逗号分隔', text: this.groupMemberIdsInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.groupMemberIdsInput = value;
            })

          if (this.groupRelationshipPickerVisible) {
            if (this.getRelatedEmployees().length === 0) {
              Text('暂无可选的关联人员。')
                .fontSize(Typography.captionSize())
                .fontColor(AppTheme.textSecondary())
            } else {
              ForEach(this.getRelatedEmployees(), (item: EmployeeDirectoryItem) => {
                Row() {
                  Column({ space: 2 }) {
                    Text(`${item.name} · ${item.jobTitle}`)
                      .fontSize(Typography.metaSize())
                      .fontColor(AppTheme.textPrimary())
                      .maxLines(1)
                    Text(`${this.getRelationshipLabel(item)} · ${item.departmentName} · ${item.id}`)
                      .fontSize(Typography.captionSize())
                      .fontColor(AppTheme.textSecondary())
                      .maxLines(1)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Button('添加')
                    .height(30)
                    .fontSize(Typography.captionSize())
                    .fontColor(AppTheme.primary())
                    .backgroundColor(AppTheme.primarySoft())
                    .borderRadius(AppTheme.radiusSmall())
                    .onClick(() => {
                      this.addParticipant(item, 'group');
                    })
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .border({ width: { bottom: 1 }, color: AppTheme.divider() })
              }, (item: EmployeeDirectoryItem) => item.id)
            }
          }

          TextInput({ placeholder: '工作组说明，可选', text: this.groupSummaryInput })
            .height(44)
            .borderRadius(AppTheme.radiusSmall())
            .backgroundColor(AppTheme.surfaceMuted())
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.groupSummaryInput = value;
            })
        }
        .width('100%')

        Button('创建工作组')
          .width('100%')
          .height(42)
          .fontColor('#FFFFFF')
          .backgroundColor(AppTheme.primary())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            void this.createGroup();
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(AppTheme.radiusMedium())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 12 }) {
          SectionBlock({ title: '协作', subtitle: `${this.user.department} · ${this.user.jobTitle}` }) {
            Column({ space: 12 }) {
              Row({ space: 8 }) {
                this.StatCard('会议', this.getCombinedMeetingItems().length, '#027A48')
                this.StatCard('工作对接', this.getCombinedTaskItems().length, '#175CD3')
                this.StatCard('工作组', this.getCombinedGroupItems().length, '#6941C6')
                this.StatCard('工作汇报', this.getCombinedChainItems().length, '#B54708')
              }
              .width('100%')

              Text(this.focus === 'action'
                ? '仅显示需要你立即处理的协作事项。'
                : this.focus === 'waiting'
                  ? '仅显示你发起后仍在等待回复的协作事项。'
                  : '围绕会议信息、工作对接、工作组和工作汇报整理协作入口。')
                .fontSize(Typography.captionSize())
                .fontColor(AppTheme.textSecondary())
                .width('100%')
            }
            .width('100%')
          }

          if (this.focus === 'all') {
            SectionBlock({ title: '新建会议', subtitle: '填写参会员工 ID 后发送待确认会议通知' }) {
              Button('填写会议信息')
                .width('100%')
                .height(42)
                .fontColor(AppTheme.primary())
                .backgroundColor(AppTheme.primarySoft())
                .borderRadius(AppTheme.radiusSmall())
                .onClick(() => {
                  this.openMeetingDialog();
                })
            }

            SectionBlock({ title: '新建对接', subtitle: '快速发起短期工作协作与回复确认' }) {
              Button('填写对接信息')
                .width('100%')
                .height(42)
                .fontColor(AppTheme.primary())
                .backgroundColor(AppTheme.primarySoft())
                .borderRadius(AppTheme.radiusSmall())
                .onClick(() => {
                  this.openTaskDialog();
                })
            }

            SectionBlock({ title: '新建工作组', subtitle: '创建长期协作空间并添加组员' }) {
              Button('填写工作组信息')
                .width('100%')
                .height(42)
                .fontColor(AppTheme.primary())
                .backgroundColor(AppTheme.primarySoft())
                .borderRadius(AppTheme.radiusSmall())
                .onClick(() => {
                  this.openGroupDialog();
                })
            }
          }

          if (this.focus !== 'waiting') {
            this.CollaborationModuleCard('meeting', '会议信息', '查看会议时间、地点和待确认事项', this.getVisibleMeetingItems().length)
          }

          this.CollaborationModuleCard('task', '工作对接', this.focus === 'all' ? '查看短期工作协作与回复确认' : '查看当前筛选下的工作对接项', this.getVisibleTaskItems().length)

          if (this.focus === 'all') {
            this.CollaborationModuleCard('group', '工作组', '查看稳定协作群组与当前状态', this.getVisibleGroupItems().length)
          }

          if (this.focus === 'all') {
            this.CollaborationModuleCard('chain', '工作汇报', '查看直属负责人和下属的汇报入口', this.getVisibleChainItems().length)
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 24 })
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')

      if (this.meetingDialogVisible) {
        this.MeetingDialog();
      }

      if (this.taskDialogVisible) {
        this.TaskDialog();
      }

      if (this.groupDialogVisible) {
        this.GroupDialog();
      }

      if (this.collaborationModuleVisible) {
        this.CollaborationModuleDialog();
      }

      if (this.conversationVisible) {
        this.ConversationDialog();
      }

      if (this.taskCloseConfirmVisible) {
        this.TaskCloseConfirmDialog();
      }
    }
    .width('100%')
    .height('100%')
  }
}
