import 'message.dart';

abstract final class Features {
  static const Feature autoSave =
      Feature(min: APIVersion(major: 0, year: 2023, month: 11, day: 30));
  static const Feature batchcommand =
      Feature(min: APIVersion(major: 0, year: 2023, month: 11, day: 30));
}

class Feature {
  const Feature({this.min, this.max});
  final APIVersion? min;
  final APIVersion? max;
  bool isSupported(APIVersion version) {
    if (min != null && min!.compareTo(version) < 0) {
      return false;
    }
    if (max != null && max!.compareTo(version) > 0) {
      return false;
    }
    return true;
  }
}
