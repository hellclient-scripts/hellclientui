import 'dart:ffi';

class Word {
  String text = "";
  String color = "";
  String background = "";
  bool bold = false;
  bool underlined = false;
  bool blinking = false;
  bool inverse = false;

  Word.fromJson(Map<String, dynamic> json)
      : text = json['Text'],
        color = json['Color'],
        background = json['Background'],
        bold = json['Bold'],
        underlined = json['Underlined'],
        blinking = json['Blinking'],
        inverse = json['Inverse'];
}

class Line {
  List<Word> words = [];
  String id = "";
  int time = 0;
  int type = 0;
  bool omitFrmLog = false;
  bool omitFromOutput = false;
  List<String> triggers = [];
  String creatorType = "";
  String creator = "";
  Line.fromJson(Map<String, dynamic> json)
      : words = List<dynamic>.from(json['Words'])
            .map((e) => Word.fromJson(e))
            .toList(),
        id = json['ID'],
        time = json['Time'],
        type = json['Type'],
        omitFrmLog = json['OmitFromLog'],
        omitFromOutput = json['OmitFromOutput'],
        triggers = (!json.containsKey('Triggers') || json['Triggers'] == null)
            ? []
            : List<dynamic>.from(json['Triggers'])
                .map((e) => e as String)
                .toList(),
        creatorType = json['CreatorType'],
        creator = json['Creator'];
}

class Lines {
  List<Line> lines = [];
  Lines.fromJson(dynamic json)
      : lines = List<dynamic>.from(json).map((e) => Line.fromJson(e)).toList();
}
