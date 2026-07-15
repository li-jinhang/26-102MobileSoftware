import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { textRecognition } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import util from '@ohos.util';
import { apiPost } from './ApiClient';
import { KnowledgeArticle } from '../../models/AppModels';

export interface OcrResult {
  success: boolean;
  previewUri: string;
  text: string;
  keywords: string[];
  relatedArticleIds: string[];
  fallbackReason: string;
  source: 'system' | 'cloud' | 'demo';
}

interface CloudOcrResponse {
  success: boolean;
  text: string;
  keywords: string[];
  fields: Record<string, string>;
  error: string;
  provider: string;
}

export const OCR_DEMO_TEXT: string = `差旅报销凭证

申请人：张晓宁
部门：产品研发部
费用类型：出租车费用
报销金额：128.50 元
发生日期：2026年7月14日
事由：前往客户现场产生的交通费用
附件：增值税电子普通发票`;

export function extractOcrKeywords(text: string): string[] {
  const candidates: string[] = ['报销', '发票', '差旅', '请假', '采购', '权限', '合同', '账号', '制度'];
  return candidates.filter((item: string) => text.includes(item)).slice(0, 5);
}

export function matchOcrArticles(text: string, articles: KnowledgeArticle[]): string[] {
  const keywords: string[] = extractOcrKeywords(text);
  return articles.filter((article: KnowledgeArticle) => {
    const source: string = `${article.title}${article.summary}${article.content}${article.categoryName}${article.tags.join('')}`;
    return keywords.some((keyword: string) => source.includes(keyword));
  }).map((article: KnowledgeArticle) => article.id);
}

export function createOcrFallback(articles: KnowledgeArticle[], reason: string, previewUri: string = ''): OcrResult {
  return {
    success: false,
    previewUri: previewUri,
    text: OCR_DEMO_TEXT,
    keywords: extractOcrKeywords(OCR_DEMO_TEXT),
    relatedArticleIds: matchOcrArticles(OCR_DEMO_TEXT, articles),
    fallbackReason: reason,
    source: 'demo'
  };
}

async function recognizeByCloud(
  pixelMap: image.PixelMap,
  articles: KnowledgeArticle[],
  previewUri: string
): Promise<OcrResult> {
  const packer = image.createImagePacker();
  const packed: ArrayBuffer = await packer.packing(pixelMap, { format: 'image/jpeg', quality: 80 });
  const helper = new util.Base64Helper();
  const imageBase64: string = helper.encodeToStringSync(new Uint8Array(packed));
  const cloud: CloudOcrResponse = await apiPost<CloudOcrResponse>(
    '/ocr/recognize',
    JSON.stringify({ imageBase64 }),
    true
  );
  if (!cloud.success || cloud.text.trim().length === 0) {
    throw new Error(cloud.error || '云端 OCR 未返回识别文本');
  }
  return {
    success: true,
    previewUri,
    text: cloud.text.trim(),
    keywords: extractOcrKeywords(cloud.text),
    relatedArticleIds: matchOcrArticles(cloud.text, articles),
    fallbackReason: '',
    source: 'cloud'
  };
}

async function recognizePixelMap(
  pixelMap: image.PixelMap,
  articles: KnowledgeArticle[],
  previewUri: string,
  fallbackPrefix: string
): Promise<OcrResult> {
  let initialized: boolean = false;
  try {
    initialized = await textRecognition.init();
    console.info(`[OCR-CAPABILITY] init=${initialized}`);
    if (!initialized) {
      throw new Error('OCR 服务初始化失败');
    }
    const recognized = await textRecognition.recognizeText({ pixelMap: pixelMap });
    const text: string = recognized.value.trim();
    if (text.length === 0) {
      throw new Error('OCR 未识别到文字');
    }
    return {
      success: true,
      previewUri: previewUri,
      text: text,
      keywords: extractOcrKeywords(text),
      relatedArticleIds: matchOcrArticles(text, articles),
      fallbackReason: '',
      source: 'system'
    };
  } catch (error) {
    console.error(`[OCR-CAPABILITY] recognize failed: ${error}`);
    try {
      return await recognizeByCloud(pixelMap, articles, previewUri);
    } catch (cloudError) {
      console.error(`[OCR-CLOUD] recognize failed: ${cloudError}`);
      return createOcrFallback(articles, `${fallbackPrefix}系统 OCR 和云端 OCR 均不可用，已显示演示识别结果。`, previewUri);
    }
  } finally {
    if (initialized) {
      try {
        await textRecognition.release();
      } catch (error) {
        console.error(`[OCR-CAPABILITY] release failed: ${error}`);
      }
    }
  }
}

export async function selectAndRecognizeImage(articles: KnowledgeArticle[]): Promise<OcrResult | null> {
  let uri: string = '';
  let file: fileIo.File | null = null;
  try {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    const selected = await picker.select(options);
    if (selected.photoUris.length === 0) {
      return null;
    }
    uri = selected.photoUris[0];
    file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    const source = image.createImageSource(file.fd);
    if (source === undefined) {
      return createOcrFallback(articles, '图片解码失败，已显示演示识别结果。', uri);
    }
    const pixelMap = await source.createPixelMap();
    return await recognizePixelMap(pixelMap, articles, uri, '所选图片');
  } catch (error) {
    console.error(`selectAndRecognizeImage failed: ${error}`);
    return createOcrFallback(articles, '当前设备暂不支持 OCR，已显示演示识别结果。', uri);
  } finally {
    if (file !== null) {
      try {
        fileIo.closeSync(file);
      } catch (error) {
        console.error(`close selected OCR image failed: ${error}`);
      }
    }
  }
}

export async function recognizeBundledDemoImage(
  context: common.Context,
  mediaResourceId: number,
  articles: KnowledgeArticle[]
): Promise<OcrResult> {
  try {
    const mediaData: Uint8Array = await context.resourceManager.getMediaContent(mediaResourceId);
    const source = image.createImageSource(mediaData.buffer as ArrayBuffer);
    if (source === undefined) {
      return createOcrFallback(articles, '内置演示图片解码失败，已显示演示识别结果。');
    }
    const pixelMap = await source.createPixelMap();
    return await recognizePixelMap(pixelMap, articles, '', '内置演示图片');
  } catch (error) {
    console.error(`recognizeBundledDemoImage failed: ${error}`);
    return createOcrFallback(articles, '当前设备暂不支持内置图片 OCR，已显示演示识别结果。');
  }
}
