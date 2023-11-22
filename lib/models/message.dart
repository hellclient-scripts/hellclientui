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

class ClientInfo {
  ClientInfo();
  String id = "";
  int readyAt = 0;
  int position = 0;
  String hostPort = "";
  String scriptID = "";
  bool running = false;
  int priority = 0;
  int lastActive = 0;
  List<Line> summary = [];
  ClientInfo.fromJson(Map<String, dynamic> json) {
    id = json["ID"];
    readyAt = json["ReadyAt"];
    position = json["Position"];
    hostPort = json["HostPort"];
    running = json["Running"];
    priority = json["Priority"];
    scriptID = json["ScriptID"];
    lastActive = json["LastActive"];
    if (json['Summary'] != null) {
      final lines = Lines.fromJson(json['Summary']);
      summary = lines.lines;
    }
  }
}

class ClientInfos {
  ClientInfos();
  List<ClientInfo> clientInfos = [];
  ClientInfos.fromJson(dynamic json)
      : clientInfos = List<dynamic>.from(json)
            .map((e) => ClientInfo.fromJson(e))
            .toList();
}

class DiffLines {
  DiffLines();
  int start = 0;
  List<Line> content = [];
  DiffLines.fromJson(Map<String, dynamic> json) {
    start = json['Start'];
    if (json["Content"] != null) {
      final lines = Lines.fromJson(json['Content']);
      content = lines.lines;
    }
  }
}

class NotOpenedGame {
  NotOpenedGame();
  String id = "";
  String lastUpdated = "";
  NotOpenedGame.fromJson(dynamic json)
      : id = json["ID"],
        lastUpdated = json["LastUpdated"];
}

class NotOpened {
  NotOpened();
  List<NotOpenedGame> games = [];
  NotOpened.fromJson(dynamic json)
      : games = List<dynamic>.from(json)
            .map((e) => NotOpenedGame.fromJson(e))
            .toList();
}

class UserInput {
  UserInput();
  String name = "";
  String script = "";
  String id = "";
  dynamic data;
  UserInput.fromJson(Map<String, dynamic> json)
      : id = json["ID"],
        script = json["Script"],
        name = json["Name"],
        data = json["Data"];
  Callback callback(int code, dynamic data) {
    final cb = Callback();
    cb.id = id;
    cb.name = name;
    cb.script = script;
    cb.code = code;
    cb.data = data;
    return cb;
  }
}

class UserInputTitleIntro {
  UserInputTitleIntro();
  String title = "";
  String intro = "";
  UserInputTitleIntro.fromJson(dynamic json)
      : title = json["Title"],
        intro = json["Intro"];
}

class UserInputTitleIntroType {
  UserInputTitleIntroType();
  String title = "";
  String intro = "";
  String type = "";
  UserInputTitleIntroType.fromJson(dynamic json)
      : title = json["Title"],
        intro = json["Intro"],
        type = json["Type"];
}

class Callback {
  String name = "";
  String script = "";
  String id = "";
  int code = 0;
  dynamic data;
  Map<String, dynamic> toJson() => {
        "Name": name,
        "Script": script,
        "ID": id,
        "Code": code,
        "data": data,
      };
}

class UserInputItem {
  UserInputItem(this.key, this.value);
  String key;
  String value;
  UserInputItem.fromJson(Map<String, dynamic> json)
      : key = json["Key"],
        value = json["Value"];
}

class UserInputList {
  UserInputList();
  String title = "";
  String intro = "";
  List<UserInputItem> items = [];
  bool mutli = false;
  List<String> values = [];
  bool withFilter = false;
  UserInputList.fromJson(Map<String, dynamic> json) {
    title = json["Title"];
    intro = json["Intro"];
    mutli = json["Mutli"];
    withFilter = json["WithFilter"];
    final valuelist = json["Values"] as List<dynamic>;
    for (final value in valuelist) {
      values.add(value);
    }
    final itemlist = json["Items"] as List<dynamic>;
    for (final item in itemlist) {
      items.add(UserInputItem.fromJson(item));
    }
  }
}
