import { KnowledgeArticle } from '../../models/AppModels';

export function filterPublishedArticles(articles: KnowledgeArticle[]): KnowledgeArticle[] {
  return articles.filter((item: KnowledgeArticle) => item.status === 'published');
}

export function searchKnowledge(
  articles: KnowledgeArticle[],
  categoryId: string,
  keyword: string
): KnowledgeArticle[] {
  const normalized: string = keyword.trim().toLowerCase();
  return filterPublishedArticles(articles).filter((item: KnowledgeArticle) => {
    const categoryMatched: boolean = categoryId === 'all' || item.categoryId === categoryId;
    const text: string = `${item.title} ${item.summary} ${item.categoryName} ${item.tags.join(' ')}`.toLowerCase();
    return categoryMatched && (normalized.length === 0 || text.includes(normalized));
  });
}

export function validateCorrection(content: string): string {
  return content.trim();
}

export function findArticle(articles: KnowledgeArticle[], articleId: string): KnowledgeArticle | null {
  const item: KnowledgeArticle | undefined = articles.find((article: KnowledgeArticle) => article.id === articleId);
  return item === undefined ? null : item;
}

export function getKnowledgeByWorkflowType(
  articles: KnowledgeArticle[],
  workflowId: string
): KnowledgeArticle[] {
  return filterPublishedArticles(articles).filter((item: KnowledgeArticle) => {
    return item.relatedWorkflowIds.includes(workflowId);
  });
}
