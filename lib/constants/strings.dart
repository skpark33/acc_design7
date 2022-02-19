// ignore_for_file: non_constant_identifier_names

class Locale {
  static String _locale = 'kr';

  static void setLocale(String val) {
    _locale = val;
  }

  static String get locale => _locale;

  static bool isKr() {
    return locale == 'kr';
  }
}

class MyStrings {
  static String apply = Locale.isKr() ? '적용' : 'Apply';
  static String close = Locale.isKr() ? '닫기' : 'Close';
  static String cancel = Locale.isKr() ? '취소' : 'Cancel';

  // layouts
  static String pages = Locale.isKr() ? '페이지' : 'Pages';
  // Menus
  static String newBook = Locale.isKr() ? "새로만들기" : 'New Book';
  static String open = Locale.isKr() ? "열기" : 'Open Book';
  static String recent = Locale.isKr() ? "최근 파일 열기" : 'Open Recently Edited';
  static String bring =
      Locale.isKr() ? "다른 패키지에서 불러오기" : 'Bring from Another Book';
  static String save = Locale.isKr() ? "저장" : 'Save';
  static String saveas = Locale.isKr() ? "다른이름 저장" : 'Save as';
  static String publish = Locale.isKr() ? "발행하기" : 'Publish';
  static String bookPropChange =
      Locale.isKr() ? "콘텐츠북 속성 변경" : 'Contents Book Properties';
  static String pageAdd = Locale.isKr() ? "페이지 추가" : 'Add Page';
  static String pagePropTitle = Locale.isKr() ? " [ 페이지 설정 ]" : 'Page Settings';
  static String widgetPropTitle =
      Locale.isKr() ? " [ 위젯 설정 ]" : 'Widget Settings';
  static String pageDesc = Locale.isKr() ? " 페이지명" : 'Page description';
  static String title = Locale.isKr() ? "제목" : 'Title';
  static String landscape = Locale.isKr() ? "가로" : 'Landscape';
  static String portrait = Locale.isKr() ? "세로" : 'Portrait';
  static String landPort = Locale.isKr() ? "가로/세로 전환" : 'Landscape or Portrait';
  static String primary = Locale.isKr() ? "프라이머리 위젯" : 'Is Primary Widget';
  static String pageSize = Locale.isKr() ? "페이지 크기" : 'Page Size';
  static String widgetSize = Locale.isKr() ? "위치 및 크기" : 'location & Size';
  static String userDefine = Locale.isKr() ? "사용자 지정" : 'User Define';
  static String width = Locale.isKr() ? "너비" : 'Width';
  static String height = Locale.isKr() ? "높이" : 'Height';
  static String bgColor = Locale.isKr() ? "배경색상" : 'Background Color';

  static String mainTitle = Locale.isKr() ? '컬러 선택' : 'Color Picker';
  static String opacity = Locale.isKr() ? '투명도' : 'Opacity';
  static String glass = Locale.isKr() ? '유리느낌' : 'Glass Feel';
  static String sourceRatio =
      Locale.isKr() ? '원본 비율대로 보기' : 'Keep source ratio';
  static String sourceRatioToggle =
      Locale.isKr() ? '꽉찬 화면으로 보기' : 'Follow frame ratio';
  static String red = Locale.isKr() ? '빨강' : 'Red';
  static String green = Locale.isKr() ? '초록' : 'Green';
  static String blue = Locale.isKr() ? '파랑' : 'Blue';
  static String hue = Locale.isKr() ? '색상' : 'Hue';
  static String saturation = Locale.isKr() ? '채도' : 'Saturation';
  static String light = Locale.isKr() ? '명도' : 'Lightness';

  static String sliderView = Locale.isKr() ? '슬라이더' : 'Sliders';
  static String matrixView = Locale.isKr() ? '매트릭스' : 'Material';

  static String frame = Locale.isKr() ? '프레임' : "Frame";
  static String text = Locale.isKr() ? '텍스트' : "Text";
  static String effect = Locale.isKr() ? '효과' : "Effect";
  static String badge = Locale.isKr() ? '뱃지' : "Badge";
  static String camera = Locale.isKr() ? '카메라' : "Camera";
  static String weather = Locale.isKr() ? '날씨' : "Weather";
  static String clock = Locale.isKr() ? '시계' : "Clock";
  static String music = Locale.isKr() ? '음악' : "Music";
  static String news = Locale.isKr() ? '뉴스' : "News";
  static String brush = Locale.isKr() ? '브러쉬' : "Brush";

  static String yes = Locale.isKr() ? '예' : "Yes";
  static String no = Locale.isKr() ? '아니오' : "No";

  static String rotate = Locale.isKr() ? '회전' : "Rotate";
  static String anime = Locale.isKr() ? '애니메이션' : "Animation";
  static String border = Locale.isKr() ? '경계선' : "Border";
  static String radius = Locale.isKr() ? '코너 라운딩' : "Corner Roundings";

  static String animeCarousel = Locale.isKr() ? '카로셀' : "Carousel";
  static String animeFlip = Locale.isKr() ? '플립' : "Flip";

  static String basicColor = Locale.isKr() ? '기본색' : "Primary";
  static String accentColor = Locale.isKr() ? '강조색' : "Accent";
  static String customColor = Locale.isKr() ? '커스텀' : "Wheel";
  static String bwColor = Locale.isKr() ? '흑백' : "black&White";
  static String bgColorCodeInput = Locale.isKr() ? '색상 코드로 입력' : "Color Code";
}
