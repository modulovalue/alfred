import '../../base/color.dart';
import '../../base/keys.dart';
import '../../base/media_query_data.dart';
import '../../base/text.dart';
import '../provider/provider.dart';
import '../stateless/stateless.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Theme extends StatelessWidget {
  final ThemeData? data;
  final Widget child;

  const Theme({
    required this.child,
    required this.data,
    Key? key,
  }) : super(key: key);

  static ThemeData? of(BuildContext context) => //
      Provider.of<ThemeData>(context);

  @override
  Widget build(BuildContext context) => //
      ValueProvider<ThemeData>(
        value: data ?? ThemeData.base(context),
        child: child,
      );
}

class ThemeData {
  final ThemeTextData text;

  const ThemeData({
    required this.text,
  });

  static double defaultParagraphFontSize(MediaSize size) {
    switch (size) {
      case MediaSize.xsmall:
        return 9;
      case MediaSize.small:
        return 10;
      case MediaSize.medium:
        return 12;
      case MediaSize.large:
        return 12;
      case MediaSize.xlarge:
        return 12;
    }
  }

  static double defaultHeader1FontSize(MediaSize size) {
    switch (size) {
      case MediaSize.xsmall:
        return 18;
      case MediaSize.small:
        return 24;
      case MediaSize.medium:
        return 32;
      case MediaSize.large:
        return 32;
      case MediaSize.xlarge:
        return 32;
    }
  }

  static double defaultHeader2FontSize(MediaSize size) {
    switch (size) {
      case MediaSize.xsmall:
        return 14;
      case MediaSize.small:
        return 18;
      case MediaSize.medium:
        return 24;
      case MediaSize.large:
        return 24;
      case MediaSize.xlarge:
        return 24;
    }
  }

  static double defaultHeader3FontSize(MediaSize size) {
    switch (size) {
      case MediaSize.xsmall:
        return 10;
      case MediaSize.small:
        return 12;
      case MediaSize.medium:
        return 24;
      case MediaSize.large:
        return 24;
      case MediaSize.xlarge:
        return 24;
    }
  }

  factory ThemeData.base(BuildContext context, {String? fontFamily}) {
    final size = MediaQuery.of(context)!.size;
    return ThemeData(
      text: ThemeTextData(
        paragraph: TextStyle(
          color: const Color(0xFF000000),
          fontSize: defaultParagraphFontSize(size),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontFamilyFallback: ['sans-serif'],
        ),
        header1: TextStyle(
          color: const Color(0xFF000000),
          fontSize: defaultHeader1FontSize(size),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontFamilyFallback: ['sans-serif'],
        ),
        header2: TextStyle(
          color: const Color(0xFF000000),
          fontSize: defaultHeader2FontSize(size),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontFamilyFallback: ['sans-serif'],
        ),
        header3: TextStyle(
          color: const Color(0xFF000000),
          fontSize: defaultHeader3FontSize(size),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontFamilyFallback: ['sans-serif'],
        ),
        activeLink: TextStyle(
          color: const Color(0xFF000000),
          fontSize: defaultParagraphFontSize(size),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontFamilyFallback: ['sans-serif'],
        ),
        inactiveLink: TextStyle(
          color: const Color(0xFF000000),
          fontSize: defaultParagraphFontSize(size),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontFamilyFallback: ['sans-serif'],
        ),
        hoverLink: TextStyle(
          color: const Color(0xFF000000),
          fontSize: defaultParagraphFontSize(size),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontFamilyFallback: ['sans-serif'],
        ),
      ),
    );
  }
}

class ThemeTextData {
  final TextStyle paragraph;
  final TextStyle header1;
  final TextStyle header2;
  final TextStyle header3;
  final TextStyle inactiveLink;
  final TextStyle activeLink;
  final TextStyle hoverLink;

  const ThemeTextData({
    required this.paragraph,
    required this.header1,
    required this.header2,
    required this.header3,
    required this.inactiveLink,
    required this.activeLink,
    required this.hoverLink,
  });
}
