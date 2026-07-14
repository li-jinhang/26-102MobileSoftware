import { markNotificationRead } from '../../common/services/MessageService';
import { AssistantHistory, AssistantReply, KnowledgeArticle, NotificationItem, ReadingFontScale, User, WorkflowInstance } from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export interface LoginStateResult {
  success: boolean;
  message: string;
  currentUser: User | null;
  favoriteKnowledgeIds: string[];
  selectedArticleId: string;
  activeTab: number;
  activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  detailReturnSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  usefulKnowledgeIds: string[];
  assistantHistory: AssistantHistory[];
  assistantQuestion: string;
  assistantReply: AssistantReply | null;
}

export interface LogoutStateResult {
  currentUser: User | null;
  activeTab: number;
  activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  selectedArticleId: string;
  favoriteKnowledgeIds: string[];
  usefulKnowledgeIds: string[];
  assistantHistory: AssistantHistory[];
  assistantQuestion: string;
  assistantReply: AssistantReply | null;
  readingFontScale: ReadingFontScale;
}

export interface OpenArticleResult {
  success: boolean;
  currentUser: User | null;
  selectedArticleId: string;
  detailReturnSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  activeSubPage: 'knowledgeDetail';
}

export interface ToggleFavoriteResult {
  favoriteKnowledgeIds: string[];
  message: string;
}

export interface WorkflowMessageNavigationResult {
  success: boolean;
  activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  detailReturnSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  activeTab: number;
  message: string;
}

function copyStringArray(source: string[]): string[] {
  const target: string[] = [];
  source.forEach((item: string) => {
    target.push(item);
  });
  return target;
}

function cloneUser(user: User): User {
  return {
    id: user.id,
    name: user.name,
    account: user.account,
    password: user.password,
    department: user.department,
    role: user.role,
    roleLabel: user.roleLabel,
    permissions: copyStringArray(user.permissions),
    favoriteKnowledgeIds: copyStringArray(user.favoriteKnowledgeIds),
    recentKnowledgeIds: copyStringArray(user.recentKnowledgeIds),
    todoCount: user.todoCount
  };
}

export function buildLoginStateUseCase(user: User): LoginStateResult {
  return {
    success: true,
    message: '',
    currentUser: user,
    favoriteKnowledgeIds: copyStringArray(user.favoriteKnowledgeIds),
    selectedArticleId: user.recentKnowledgeIds.length > 0 ? user.recentKnowledgeIds[0] : 'k1',
    activeTab: 0,
    activeSubPage: 'none',
    detailReturnSubPage: 'none',
    usefulKnowledgeIds: [],
    assistantHistory: [],
    assistantQuestion: '',
    assistantReply: null
  };
}

export function buildLogoutStateUseCase(): LogoutStateResult {
  return {
    currentUser: null,
    activeTab: 0,
    activeSubPage: 'none',
    selectedArticleId: 'k2',
    favoriteKnowledgeIds: [],
    usefulKnowledgeIds: [],
    assistantHistory: [],
    assistantQuestion: '',
    assistantReply: null,
    readingFontScale: 'standard'
  };
}

export function buildOpenArticleStateUseCase(
  currentUser: User | null,
  article: KnowledgeArticle | null,
  articleId: string,
  activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages'
): OpenArticleResult {
  if (currentUser === null || article === null) {
    return {
      success: false,
      currentUser: currentUser,
      selectedArticleId: articleId,
      detailReturnSubPage: activeSubPage,
      activeSubPage: 'knowledgeDetail'
    };
  }

  const recentIds: string[] = [articleId];
  currentUser.recentKnowledgeIds.forEach((id: string) => {
    if (id !== articleId && recentIds.length < 3) {
      recentIds.push(id);
    }
  });
  const updatedUser: User = cloneUser(currentUser);
  updatedUser.recentKnowledgeIds = recentIds;

  return {
    success: true,
    currentUser: updatedUser,
    selectedArticleId: articleId,
    detailReturnSubPage: activeSubPage,
    activeSubPage: 'knowledgeDetail'
  };
}

export function toggleFavoriteStateUseCase(favoriteKnowledgeIds: string[], articleId: string): ToggleFavoriteResult {
  if (favoriteKnowledgeIds.includes(articleId)) {
    return {
      favoriteKnowledgeIds: favoriteKnowledgeIds.filter((item: string) => item !== articleId),
      message: '已取消收藏。'
    };
  }

  const favorites: string[] = [articleId];
  favoriteKnowledgeIds.forEach((item: string) => {
    favorites.push(item);
  });
  return {
    favoriteKnowledgeIds: favorites,
    message: '已加入收藏。'
  };
}

export async function markNotificationReadStateUseCase(
  notifications: NotificationItem[],
  notificationId: string
): Promise<NotificationItem[]> {
  await repositories.notificationRepository.markRead(notificationId);
  return markNotificationRead(notifications, notificationId);
}

export function buildWorkflowMessageNavigationStateUseCase(
  workflowInstances: WorkflowInstance[],
  instanceId: string
): WorkflowMessageNavigationResult {
  const exists: boolean = workflowInstances.some((item: WorkflowInstance) => item.id === instanceId);
  if (!exists) {
    return {
      success: false,
      activeSubPage: 'none',
      detailReturnSubPage: 'none',
      activeTab: 2,
      message: '关联流程暂不可用。'
    };
  }

  return {
    success: true,
    activeSubPage: 'none',
    detailReturnSubPage: 'none',
    activeTab: 2,
    message: '已进入流程页面。'
  };
}
