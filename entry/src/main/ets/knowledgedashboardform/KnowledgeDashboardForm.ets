import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import {
  DashboardSummary,
  loadDashboardSummary,
  removeDashboardFormId,
  saveDashboardFormId
} from '../common/services/ExperienceStateService';
import { preferences } from '@kit.ArkData';

export default class KnowledgeDashboardForm extends FormExtensionAbility {
  onAddForm(want: Want) {
    const formId: string = `${want.parameters?.[formInfo.FormParam.IDENTITY_KEY] ?? ''}`;
    if (formId.length > 0) {
      this.initializeForm(formId);
    }
    return formBindingData.createFormBindingData({
      data: JSON.stringify({
        todoCount: 0,
        unreadCount: 0,
        recentTitle: '打开知识库'
      })
    });
  }

  private async initializeForm(formId: string): Promise<void> {
    await saveDashboardFormId(this.context as common.Context, formId);
    const summary: DashboardSummary = await loadDashboardSummary(this.context as common.Context);
    try {
      await formProvider.updateForm(formId, formBindingData.createFormBindingData({
        data: JSON.stringify(summary)
      }));
    } catch (error) {
      console.error(`KnowledgeDashboardForm initialize failed: ${error}`);
    }
  }

  async onUpdateForm(formId: string): Promise<void> {
    try {
      const store = await preferences.getPreferences(this.context, 'zhixieku_experience');
      const summary: DashboardSummary = JSON.parse(
        await store.get('dashboard_summary', JSON.stringify({
          todoCount: 0,
          unreadCount: 0,
          recentTitle: '打开知识库'
        })) as string
      ) as DashboardSummary;
      await formProvider.updateForm(formId, formBindingData.createFormBindingData(summary));
    } catch (error) {
      console.error(`KnowledgeDashboardForm update failed: ${error}`);
    }
  }

  onRemoveForm(formId: string): void {
    removeDashboardFormId(this.context as common.Context, formId);
  }
}
