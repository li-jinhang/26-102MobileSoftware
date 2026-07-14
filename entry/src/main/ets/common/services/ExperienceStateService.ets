import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { formBindingData, formProvider } from '@kit.FormKit';
import { ReadingFontScale, ReadingFontWeight } from '../../models/AppModels';

export interface DashboardSummary {
  todoCount: number;
  unreadCount: number;
  recentTitle: string;
}

export interface ReadingSettings {
  scale: ReadingFontScale;
  weight: ReadingFontWeight;
}

const STORE_NAME: string = 'zhixieku_experience';
const SUMMARY_KEY: string = 'dashboard_summary';
const READING_KEY: string = 'reading_settings';
const FORM_IDS_KEY: string = 'dashboard_form_ids';

export async function loadDashboardSummary(context: common.Context): Promise<DashboardSummary> {
  const fallback: DashboardSummary = { todoCount: 0, unreadCount: 0, recentTitle: '打开知识库' };
  try {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw: string = await store.get(SUMMARY_KEY, JSON.stringify(fallback)) as string;
    return JSON.parse(raw) as DashboardSummary;
  } catch (error) {
    console.error(`loadDashboardSummary failed: ${error}`);
    return fallback;
  }
}

export function loadDashboardSummarySync(context: common.Context): DashboardSummary {
  const fallback: DashboardSummary = { todoCount: 0, unreadCount: 0, recentTitle: '打开知识库' };
  try {
    const store = preferences.getPreferencesSync(context, { name: STORE_NAME });
    const raw: string = store.getSync(SUMMARY_KEY, JSON.stringify(fallback)) as string;
    return JSON.parse(raw) as DashboardSummary;
  } catch (error) {
    console.error(`loadDashboardSummarySync failed: ${error}`);
    return fallback;
  }
}

export async function saveDashboardSummary(
  context: common.Context,
  summary: DashboardSummary
): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(SUMMARY_KEY, JSON.stringify(summary));
    await store.flush();
    const runningForms = await formProvider.getPublishedRunningFormInfos();
    const formIds: string[] = runningForms
      .filter((item) => item.formName === 'KnowledgeDashboardForm')
      .map((item) => item.formId);
    for (let index: number = 0; index < formIds.length; index++) {
      try {
        await formProvider.updateForm(formIds[index], formBindingData.createFormBindingData({
          data: JSON.stringify(summary)
        }));
      } catch (error) {
        console.error(`update dashboard form ${formIds[index]} failed: ${error}`);
      }
    }
  } catch (error) {
    console.error(`saveDashboardSummary failed: ${error}`);
  }
}

export async function saveDashboardFormId(context: common.Context, formId: string): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const formIds: string[] = JSON.parse(await store.get(FORM_IDS_KEY, '[]') as string) as string[];
    if (!formIds.includes(formId)) {
      formIds.push(formId);
      await store.put(FORM_IDS_KEY, JSON.stringify(formIds));
      await store.flush();
    }
  } catch (error) {
    console.error(`saveDashboardFormId failed: ${error}`);
  }
}

export async function removeDashboardFormId(context: common.Context, formId: string): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const formIds: string[] = JSON.parse(await store.get(FORM_IDS_KEY, '[]') as string) as string[];
    await store.put(FORM_IDS_KEY, JSON.stringify(formIds.filter((item: string) => item !== formId)));
    await store.flush();
  } catch (error) {
    console.error(`removeDashboardFormId failed: ${error}`);
  }
}

export function saveDashboardFormIdSync(context: common.Context, formId: string): void {
  try {
    const store = preferences.getPreferencesSync(context, { name: STORE_NAME });
    const formIds: string[] = JSON.parse(store.getSync(FORM_IDS_KEY, '[]') as string) as string[];
    if (!formIds.includes(formId)) {
      formIds.push(formId);
      store.putSync(FORM_IDS_KEY, JSON.stringify(formIds));
      store.flushSync();
    }
  } catch (error) {
    console.error(`saveDashboardFormIdSync failed: ${error}`);
  }
}

export function removeDashboardFormIdSync(context: common.Context, formId: string): void {
  try {
    const store = preferences.getPreferencesSync(context, { name: STORE_NAME });
    const formIds: string[] = JSON.parse(store.getSync(FORM_IDS_KEY, '[]') as string) as string[];
    store.putSync(FORM_IDS_KEY, JSON.stringify(formIds.filter((item: string) => item !== formId)));
    store.flushSync();
  } catch (error) {
    console.error(`removeDashboardFormIdSync failed: ${error}`);
  }
}

export async function loadReadingSettings(context: common.UIAbilityContext): Promise<ReadingSettings> {
  const fallback: ReadingSettings = { scale: 'standard', weight: 'standard' };
  try {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw: string = await store.get(READING_KEY, JSON.stringify(fallback)) as string;
    const value: ReadingSettings = JSON.parse(raw) as ReadingSettings;
    return value.scale && value.weight ? value : fallback;
  } catch (error) {
    console.error(`loadReadingSettings failed: ${error}`);
    return fallback;
  }
}

export async function saveReadingSettings(
  context: common.UIAbilityContext,
  settings: ReadingSettings
): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(READING_KEY, JSON.stringify(settings));
    await store.flush();
  } catch (error) {
    console.error(`saveReadingSettings failed: ${error}`);
  }
}
