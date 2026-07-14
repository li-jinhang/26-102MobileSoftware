import { validateCorrection } from '../../common/services/KnowledgeService';
import { KnowledgeCorrection } from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export interface SubmitCorrectionResult {
  success: boolean;
  corrections: KnowledgeCorrection[];
}

export interface ToggleFavoriteResult {
  favoriteKnowledgeIds: string[];
  message: string;
}

export function markKnowledgeUsefulStateUseCase(usefulKnowledgeIds: string[], articleId: string): string[] {
  if (usefulKnowledgeIds.includes(articleId)) {
    return usefulKnowledgeIds;
  }

  const ids: string[] = [articleId];
  usefulKnowledgeIds.forEach((item: string) => {
    ids.push(item);
  });
  return ids;
}

export async function submitCorrectionStateUseCase(
  corrections: KnowledgeCorrection[],
  articleId: string,
  content: string
): Promise<SubmitCorrectionResult> {
  const normalized: string = validateCorrection(content);
  if (normalized.length === 0) {
    return {
      success: false,
      corrections: corrections
    };
  }

  const correction: KnowledgeCorrection = await repositories.knowledgeRepository.createCorrection(articleId, normalized);
  const list: KnowledgeCorrection[] = [correction];
  corrections.forEach((item: KnowledgeCorrection) => {
    list.push(item);
  });
  return {
    success: true,
    corrections: list
  };
}

export function isFavoriteKnowledgeUseCase(favoriteKnowledgeIds: string[], articleId: string): boolean {
  return favoriteKnowledgeIds.includes(articleId);
}

export async function toggleFavoriteKnowledgeUseCase(
  favoriteKnowledgeIds: string[],
  articleId: string
): Promise<ToggleFavoriteResult> {
  if (favoriteKnowledgeIds.includes(articleId)) {
    const favorite: boolean = await repositories.knowledgeRepository.unfavorite(articleId);
    return {
      favoriteKnowledgeIds: favoriteKnowledgeIds.filter((item: string) => item !== articleId),
      message: favorite ? '已加入收藏。' : '已取消收藏。'
    };
  }

  const favorite: boolean = await repositories.knowledgeRepository.favorite(articleId);
  const favorites: string[] = [articleId];
  favoriteKnowledgeIds.forEach((item: string) => {
    favorites.push(item);
  });
  return {
    favoriteKnowledgeIds: favorites,
    message: favorite ? '已加入收藏。' : '已取消收藏。'
  };
}
