import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import util from '@ohos.util';
import { AssistantSelectedImage } from '../../models/AppModels';

export async function selectAssistantImage(): Promise<AssistantSelectedImage | null> {
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

    const previewUri: string = selected.photoUris[0];
    file = fileIo.openSync(previewUri, fileIo.OpenMode.READ_ONLY);
    const source = image.createImageSource(file.fd);
    if (source === undefined) {
      throw new Error('图片解码失败，请重新选择。');
    }
    const pixelMap = await source.createPixelMap();
    const packer = image.createImagePacker();
    const packed: ArrayBuffer = await packer.packing(pixelMap, { format: 'image/jpeg', quality: 80 });
    const helper = new util.Base64Helper();
    const result: AssistantSelectedImage = {
      previewUri,
      imageBase64: helper.encodeToStringSync(new Uint8Array(packed)),
      imageMimeType: 'image/jpeg'
    };
    return result;
  } finally {
    if (file !== null) {
      try {
        fileIo.closeSync(file);
      } catch (error) {
        console.error(`close assistant image failed: ${error}`);
      }
    }
  }
}
