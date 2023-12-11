class Macros {
  Macros();
  String f1 = '';
  String f2 = '';
  String f3 = '';
  String f4 = '';
  String f5 = '';
  String f6 = '';
  String f7 = '';
  String f8 = '';
  String f9 = '';
  String f10 = '';
  String f11 = '';
  String f12 = '';
  String numpad0 = '';
  String numpad1 = '';
  String numpad2 = '';
  String numpad3 = '';
  String numpad4 = '';
  String numpad5 = '';
  String numpad6 = '';
  String numpad7 = '';
  String numpad8 = '';
  String numpad9 = '';
  String numpadDivide = '';
  String numpadMultiply = '';
  String numpadSubtract = '';
  String numpadAdd = '';
  String numpadDecimal = '';
  Macros.fromJson(Map<String, dynamic> json) {
    f1 = json['f1'] ?? '';
    f2 = json['f2'] ?? '';
    f3 = json['f3'] ?? '';
    f4 = json['f4'] ?? '';
    f5 = json['f5'] ?? '';
    f6 = json['f6'] ?? '';
    f7 = json['f7'] ?? '';
    f8 = json['f8'] ?? '';
    f9 = json['f9'] ?? '';
    f10 = json['f10'] ?? '';
    f11 = json['f11'] ?? '';
    f12 = json['f12'] ?? '';
    numpad0 = json['numpad0'] ?? '';
    numpad1 = json['numpad1'] ?? '';
    numpad2 = json['numpad2'] ?? '';
    numpad3 = json['numpad3'] ?? '';
    numpad4 = json['numpad4'] ?? '';
    numpad5 = json['numpad5'] ?? '';
    numpad6 = json['numpad6'] ?? '';
    numpad7 = json['numpad7'] ?? '';
    numpad8 = json['numpad8'] ?? '';
    numpad9 = json['numpad9'] ?? '';
    numpadDivide = json['numpadDivide'] ?? '';
    numpadMultiply = json['numpadMultiply'] ?? '';
    numpadSubtract = json['numpadSubtract'] ?? '';
    numpadAdd = json['numpadAdd'] ?? '';
    numpadDecimal = json['numpadDecimal'] ?? '';
  }
  Map<String, dynamic> toJson() => {
        'f1': f1,
        'f2': f2,
        'f3': f3,
        'f4': f4,
        'f5': f5,
        'f6': f6,
        'f7': f7,
        'f8': f8,
        'f9': f9,
        'f10': f10,
        'f11': f11,
        'f12': f12,
        'numpad0': numpad0,
        'numpad1': numpad1,
        'numpad2': numpad2,
        'numpad3': numpad3,
        'numpad4': numpad4,
        'numpad5': numpad5,
        'numpad6': numpad6,
        'numpad7': numpad7,
        'numpad8': numpad8,
        'numpad9': numpad9,
        'numpadDivide': numpadDivide,
        'numpadMultiply': numpadMultiply,
        'numpadSubtract': numpadSubtract,
        'numpadAdd': numpadAdd,
        'numpadDecimal': numpadDecimal,
      };
  Macros clone() {
    return Macros.fromJson(toJson());
  }
}
