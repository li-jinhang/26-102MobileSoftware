import { ReadingFontScale, ReadingFontWeight } from '../../models/AppModels';

export class Typography {
  static displaySize(): number {
    return 34;
  }

  static pageTitleSize(): number {
    return 22;
  }

  static detailTitleSize(): number {
    return 24;
  }

  static sectionTitleSize(): number {
    return 17;
  }

  static cardTitleSize(): number {
    return 15;
  }

  static bodySize(): number {
    return 14;
  }

  static bodyLargeSize(): number {
    return 15;
  }

  static metaSize(): number {
    return 12;
  }

  static captionSize(): number {
    return 11;
  }

  static microSize(): number {
    return 10;
  }

  static iconBackSize(): number {
    return 30;
  }

  static bodyLineHeight(): number {
    return 22;
  }

  static bodyLargeLineHeight(): number {
    return 24;
  }

  static detailTitleLineHeight(): number {
    return 32;
  }

  static summaryLineHeight(): number {
    return 18;
  }

  static readingSize(scale: ReadingFontScale): number {
    if (scale === 'small') {
      return 14;
    }
    if (scale === 'large') {
      return 19;
    }
    return 16;
  }

  static readingLineHeight(scale: ReadingFontScale): number {
    if (scale === 'small') {
      return 22;
    }
    if (scale === 'large') {
      return 30;
    }
    return 26;
  }

  static readingWeight(weight: ReadingFontWeight): FontWeight {
    return weight === 'semiBold' ? FontWeight.Medium : FontWeight.Regular;
  }

  static titleWeight(): FontWeight {
    return FontWeight.Medium;
  }

  static emphasisWeight(): FontWeight {
    return FontWeight.Medium;
  }
}
