import { AppTopBar } from '../../common/components/AppTopBar';
import { AppTheme } from '../../common/theme/AppTheme';
import { AssistantMailDraft, EmployeeDirectoryItem, OrganizationProfile } from '../../models/AppModels';

@Component
export struct MailComposerPage {
  @Require @Prop profile: OrganizationProfile | null;
  @Prop draft: AssistantMailDraft | null = null;
  onBack: () => void = () => {
  };
  onSend: (
    receiverIds: string[],
    subject: string,
    content: string,
    relatedWorkflowId: string,
    relatedKnowledgeId: string
  ) => void = () => {
  };
  @State receiverInput: string = '';
  @State subjectInput: string = '';
  @State contentInput: string = '';
  @State relatedWorkflowId: string = '';
  @State relatedKnowledgeId: string = '';
  @State assistantDescription: string = '';
  @State relationshipPickerVisible: boolean = false;

  private getRelatedEmployees(): EmployeeDirectoryItem[] {
    if (this.profile === null) {
      return [];
    }
    const profile: OrganizationProfile = this.profile;
    const employees: EmployeeDirectoryItem[] = [];
    if (profile.manager !== null) {
      employees.push(profile.manager);
    }
    profile.directReports.forEach((item: EmployeeDirectoryItem) => {
      if (!employees.some((employee: EmployeeDirectoryItem) => employee.id === item.id)) {
        employees.push(item);
      }
    });
    profile.departmentMembers.forEach((item: EmployeeDirectoryItem) => {
      if (item.id !== profile.employee.id && !employees.some((employee: EmployeeDirectoryItem) => employee.id === item.id)) {
        employees.push(item);
      }
    });
    return employees;
  }

  private addReceiver(employee: EmployeeDirectoryItem): void {
    const receiverIds: string[] = this.getReceiverIds();
    if (!receiverIds.includes(employee.id)) {
      receiverIds.push(employee.id);
      this.receiverInput = receiverIds.join(', ');
    }
  }

  private getRelationshipLabel(employee: EmployeeDirectoryItem): string {
    const profile: OrganizationProfile | null = this.profile;
    if (profile !== null && profile.manager !== null && profile.manager.id === employee.id) {
      return '上级';
    }
    if (profile !== null && profile.directReports.some((item: EmployeeDirectoryItem) => item.id === employee.id)) {
      return '下级';
    }
    return '工作组 / 对接';
  }

  private fillMailWithAssistant(): void {
    const description: string = this.assistantDescription.trim();
    if (description.length === 0) {
      return;
    }
    const relatedEmployees: EmployeeDirectoryItem[] = this.getRelatedEmployees();
    const matched: EmployeeDirectoryItem | undefined = relatedEmployees.find((employee: EmployeeDirectoryItem) => {
      return description.includes(employee.name) || description.includes(employee.jobTitle);
    });
    const profile: OrganizationProfile | null = this.profile;
    const manager: EmployeeDirectoryItem | null = profile === null ? null : profile.manager;
    if (matched !== undefined) {
      this.receiverInput = matched.id;
    } else if (manager !== null && /上级|领导|经理|直属负责人/.test(description)) {
      this.receiverInput = manager.id;
    } else if (profile !== null && /下级|下属/.test(description) && profile.directReports.length > 0) {
      this.receiverInput = profile.directReports.map((item: EmployeeDirectoryItem) => item.id).join(', ');
    } else if (profile !== null && /同事|工作组|组员|对接/.test(description)) {
      const employeeId: string = profile.employee.id;
      const groupMembers: EmployeeDirectoryItem[] = profile.departmentMembers;
      this.receiverInput = groupMembers
        .filter((item: EmployeeDirectoryItem) => item.id !== employeeId)
        .map((item: EmployeeDirectoryItem) => item.id)
        .join(', ');
    } else if (this.getReceiverIds().length === 0 && relatedEmployees.length > 0) {
      this.receiverInput = relatedEmployees[0].id;
    }
    this.subjectInput = description.length > 22 ? `${description.slice(0, 22)}...` : description;
    this.contentInput = `您好，\n\n${description}\n\n请查收并确认，谢谢。`;
  }

  aboutToAppear(): void {
    if (this.draft === null) {
      this.receiverInput = '';
      this.subjectInput = '';
      this.contentInput = '';
      this.relatedWorkflowId = '';
      this.relatedKnowledgeId = '';
      this.assistantDescription = '';
      return;
    }
    this.receiverInput = this.draft.receiverIds.join(', ');
    this.subjectInput = this.draft.subject;
    this.contentInput = this.draft.content;
  }

  private getReceiverIds(): string[] {
    return this.receiverInput
      .split(',')
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0);
  }

  private canSend(): boolean {
    return this.getReceiverIds().length > 0 && this.subjectInput.trim().length > 0 && this.contentInput.trim().length > 0;
  }

  build() {
    Column({ space: 14 }) {
      AppTopBar({ title: '写邮件', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: 12 }) {
        Column({ space: 8 }) {
          Text('智能助手')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.textPrimary())
          TextArea({ placeholder: '描述邮件目的、收件人或需要跟进的事项', text: this.assistantDescription })
            .width('100%')
            .height(78)
            .backgroundColor('#F8FAFC')
            .border({ width: 1, color: AppTheme.border() })
            .borderRadius(8)
            .padding(10)
            .onChange((value: string) => {
              this.assistantDescription = value;
            })
          Button('自动填写邮件')
            .height(36)
            .fontSize(13)
            .fontColor(AppTheme.primary())
            .backgroundColor(AppTheme.primarySoft())
            .borderRadius(8)
            .enabled(this.assistantDescription.trim().length > 0)
            .onClick(() => {
              this.fillMailWithAssistant();
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)

        Column({ space: 6 }) {
          Row() {
            Text('收件人')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.textPrimary())
            Blank()
            Text('从关联人员选择')
              .fontSize(13)
              .fontColor(AppTheme.primary())
              .onClick(() => {
                this.relationshipPickerVisible = !this.relationshipPickerVisible;
              })
          }
          .width('100%')
        TextInput({ placeholder: '收件人 ID，多个用英文逗号分隔', text: this.receiverInput })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.receiverInput = value;
          })

          if (this.relationshipPickerVisible) {
            if (this.getRelatedEmployees().length === 0) {
              Text('暂无可选的对接、工作组或上下级关系人员。')
                .fontSize(12)
                .fontColor(AppTheme.textSecondary())
            } else {
              ForEach(this.getRelatedEmployees(), (item: EmployeeDirectoryItem) => {
                Row() {
                  Column({ space: 2 }) {
                    Text(`${item.name} · ${item.jobTitle}`)
                      .fontSize(13)
                      .fontColor(AppTheme.textPrimary())
                      .maxLines(1)
                    Text(`${this.getRelationshipLabel(item)} · ${item.departmentName} · ${item.id}`)
                      .fontSize(11)
                      .fontColor(AppTheme.textSecondary())
                      .maxLines(1)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Button('添加')
                    .height(30)
                    .fontSize(12)
                    .fontColor(AppTheme.primary())
                    .backgroundColor(AppTheme.primarySoft())
                    .borderRadius(8)
                    .onClick(() => {
                      this.addReceiver(item);
                    })
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .border({ width: { bottom: 1 }, color: AppTheme.divider() })
              }, (item: EmployeeDirectoryItem) => item.id)
            }
          }
        }
        .width('100%')

        TextInput({ placeholder: '邮件主题', text: this.subjectInput })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.subjectInput = value;
          })

        TextArea({ placeholder: '邮件正文', text: this.contentInput })
          .width('100%')
          .height(120)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.contentInput = value;
          })

        TextInput({ placeholder: '关联流程 ID（可选）', text: this.relatedWorkflowId })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.relatedWorkflowId = value;
          })

        TextInput({ placeholder: '关联知识 ID（可选）', text: this.relatedKnowledgeId })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.relatedKnowledgeId = value;
          })

      Button('发送邮件')
        .width('100%')
        .height(44)
        .fontColor('#FFFFFF')
        .backgroundColor(this.canSend() ? '#175CD3' : '#D0D5DD')
        .borderRadius(12)
        .enabled(this.canSend())
        .onClick(() => {
          this.onSend(
            this.getReceiverIds(),
            this.subjectInput,
            this.contentInput,
            this.relatedWorkflowId.trim(),
            this.relatedKnowledgeId.trim()
          );
        })
        }
        .width('100%')
        .padding({ bottom: 24 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(AppTheme.pageBackground())
  }
}
