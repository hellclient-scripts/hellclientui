import 'message.dart';

abstract final class Features {
  static const Feature autoSave =
      Feature(min: APIVersion(major: 0, year: 2023, month: 11, day: 30));
  static const Feature batchcommand =
      Feature(min: APIVersion(major: 0, year: 2023, month: 11, day: 30));
  static const Feature onLoseFocus =
      Feature(min: APIVersion(major: 1, year: 2024, month: 06, day: 23));
}

class Feature {
  const Feature({this.min, this.max});
  final APIVersion? min;
  final APIVersion? max;
  bool isSupportedBy(APIVersion apiversion) {
    if (min != null && apiversion.compareTo(min!) < 0) {
      return false;
    }
    if (max != null && apiversion.compareTo(max!) > 0) {
      return false;
    }
    return true;
  }
}
