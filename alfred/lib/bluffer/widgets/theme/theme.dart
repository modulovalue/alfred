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
    required final this.child,
    required final this.data,
    final Key? key,
  }) : super(key: key);

  static ThemeData? of(
    final BuildContext context,
  ) =>
      Provider.of<ThemeData>(context);

  @override
  Widget build(
    final BuildContext context,
  ) =>
      ValueProvider<ThemeData>(
        value: data ?? ThemeData.base(context),
        child: child,
      );
}

class ThemeData {
  final ThemeTextData text;

  const ThemeData({
    required final this.text,
  });

  static ThemeData base(
    final BuildContext context,
  ) {
    final size = MediaQuery.of(context)!.size;
    return ThemeData(
      text: ThemeTextData(
        paragraph: ThemeDataDefaults.paragraph(size: size),
        header1: ThemeDataDefaults.header1(size: size),
        header2: ThemeDataDefaults.header2(size: size),
        header3: ThemeDataDefaults.header3(size: size),
        activeLink: ThemeDataDefaults.activeLink(size: size),
        inactiveLink: ThemeDataDefaults.inactiveLink(size: size),
        hoverLink: ThemeDataDefaults.hoverLink(size: size),
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
    required final this.paragraph,
    required final this.header1,
    required final this.header2,
    required final this.header3,
    required final this.inactiveLink,
    required final this.activeLink,
    required final this.hoverLink,
  });
}

abstract class ThemeDataDefaults {
  static TextStyle paragraph({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle header1({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultHeader1FontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle header2({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultHeader2FontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle header3({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultHeader3FontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle activeLink({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle inactiveLink({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle hoverLink({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static double defaultParagraphFontSize(
    final MediaSize size,
  ) {
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

  static double defaultHeader1FontSize(
    final MediaSize size,
  ) {
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

  static double defaultHeader2FontSize(
    final MediaSize size,
  ) {
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

  static double defaultHeader3FontSize(
    final MediaSize size,
  ) {
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
}
