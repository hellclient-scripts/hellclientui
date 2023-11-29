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
  Line();
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
  Lines.fromJson(dynamic json) {
    if (json != null) {
      lines = List<dynamic>.from(json)
          .map((e) => e == null ? Line() : Line.fromJson(e))
          .toList();
    }
  }
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
      : title = json["Title"] ??= "",
        intro = json["Intro"] ??= "";
}

class UserInputTitleIntroType {
  UserInputTitleIntroType();
  String title = "";
  String intro = "";
  String type = "";
  UserInputTitleIntroType.fromJson(dynamic json)
      : title = json["Title"] ??= "",
        intro = json["Intro"] ??= "",
        type = json["Type"] ??= "";
}

class UserInputTitleBodyType {
  UserInputTitleBodyType();
  String title = "";
  String body = "";
  String type = "";
  UserInputTitleBodyType.fromJson(dynamic json)
      : title = json["Title"] ??= "",
        body = json["Body"] ??= "",
        type = json["Type"] ??= "";
}

class UserInputTitleIntroValue {
  UserInputTitleIntroValue();
  String title = "";
  String intro = "";
  String value = "";
  UserInputTitleIntroValue.fromJson(dynamic json)
      : title = json["Title"] ??= "",
        intro = json["Intro"] ??= "",
        value = json["Value"] ??= "";
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
    if (json["Items"] != null) {
      final itemlist = json["Items"] as List<dynamic>;
      for (final item in itemlist) {
        items.add(UserInputItem.fromJson(item));
      }
    }
  }
}

class VisualPrompt {
  VisualPrompt();
  String title = "";
  String intro = "";
  String source = "";
  String mediaType = "";
  String value = "";
  List<UserInputItem> items = [];
  bool portrait = false;
  String refreshCallback = "";
  VisualPrompt.fromJson(Map<String, dynamic> json) {
    title = json["Title"];
    intro = json["Intro"];
    source = json["Source"];
    mediaType = json["MediaType"];
    value = json["Value"];
    portrait = json["Portrait"];
    refreshCallback = json["RefreshCallback"];
    if (json["Items"] != null) {
      final itemlist = json["Items"] as List<dynamic>;
      for (final item in itemlist) {
        items.add(UserInputItem.fromJson(item));
      }
    }
  }
}

class FieldError {
  FieldError();
  String field = "";
  String label = "";
  String msg = "";
  FieldError.fromJson(Map<String, dynamic> json) {
    field = json["Field"];
    label = json["Label"];
    msg = json["Msg"];
  }
}

class CreateFail {
  CreateFail();
  List<FieldError> errors = [];
  CreateFail.fromJson(dynamic json) {
    errors =
        List<dynamic>.from(json).map((e) => FieldError.fromJson(e)).toList();
  }
}

class UpdatePasswordForm {
  UpdatePasswordForm(
      {required this.username,
      required this.password,
      required this.repeatPassword});
  String username = "";
  String password = "";
  String repeatPassword = "";
  Map<String, dynamic> toJson() => {
        "Username": username,
        "Password": password,
        "RepeatPassword": repeatPassword
      };
}

class CreateGameForm {
  CreateGameForm({
    required this.id,
    required this.host,
    required this.port,
    required this.charset,
  });
  String id = "";
  String host = "";
  String port = "";
  String charset = "";
  Map<String, dynamic> toJson() => {
        "ID": id,
        "Host": host,
        "Port": port,
        "Charset": charset,
      };
}

class CreateScriptForm {
  CreateScriptForm({
    required this.id,
    required this.type,
  });
  String id = "";
  String type = "";
  Map<String, dynamic> toJson() => {
        'ID': id,
        'Type': type,
      };
}

class FoundHistory {
  FoundHistory();
  int position = 0;
  String command = "";
  FoundHistory.fromJson(Map<String, dynamic> json) {
    position = json['Position'] ?? 0;
    command = json['Command'] ?? "";
  }
}

class Authorized {
  Authorized();
  List<String> permissions = [];
  List<String> domains = [];
  Authorized.fromJson(Map<String, dynamic> json) {
    if (json['Permissions'] != null) {
      permissions = List<dynamic>.from(json['Permissions'])
          .map((e) => e as String)
          .toList();
    }
    if (json['Domains'] != null) {
      domains =
          List<dynamic>.from(json['Domains']).map((e) => e as String).toList();
    }
  }
}

class RequestTrust {
  RequestTrust();
  List<String> items = [];
  String reason = '';
  String script = '';
  String world = '';
  RequestTrust.fromJson(Map<String, dynamic> json) {
    reason = json['Reason'] ?? '';
    script = json['Script'] ?? '';
    world = json['World'] ?? '';
    if (json['Items'] != null) {
      items =
          List<dynamic>.from(json['Items']).map((e) => e as String).toList();
    }
  }
  Map<String, dynamic> toJson() => {
        'Reason': reason,
        'Script': script,
        'World': world,
        'Items': items.map((e) => e as dynamic).toList(),
      };
}

class WorldSettings {
  WorldSettings({
    required this.id,
    required this.host,
    required this.port,
    required this.charset,
    required this.proxy,
    required this.name,
    required this.scriptPrefix,
    required this.commandStackCharacter,
    required this.showBroadcast,
    required this.showSubneg,
    required this.modEnabled,
  });
  String id = "";
  String host = "";
  String port = "";
  String charset = "";
  String proxy = "";
  String name = "";
  String scriptPrefix = "";
  String commandStackCharacter = "";
  bool showBroadcast = false;
  bool showSubneg = false;
  bool modEnabled = false;
  WorldSettings.fromJson(Map<String, dynamic> json) {
    id = json['ID'] ?? '';
    host = json['Host'] ?? '';
    port = json['Port'] ?? '';
    charset = json['Charset'] ?? '';
    proxy = json['Proxy'] ?? '';
    name = json['Name'] ?? '';
    scriptPrefix = json['ScriptPrefix'] ?? '';
    commandStackCharacter = json['CommandStackCharacter'] ?? '';
    showBroadcast = json['ShowBroadcast'] ?? false;
    showSubneg = json['ShowSubneg'] ?? false;
    modEnabled = json['ModEnabled'] ?? false;
  }
  Map<String, dynamic> toJson() => {
        'ID': id,
        'Host': host,
        'Port': port,
        'Charset': charset,
        'Proxy': proxy,
        'Name': name,
        'ScriptPrefix': scriptPrefix,
        'CommandStackCharacter': commandStackCharacter,
        'ShowBroadcast': showBroadcast,
        'ShowSubneg': showSubneg,
        'ModEnabled': modEnabled,
      };
}

class ScriptInfo {
  String desc = "";
  String id = "";
  String intro = "";
  String onAssist = "";
  String onBroadCast = "";
  String onBuffer = "";
  int onBufferMax = 0;
  int onBufferMin = 0;
  String onClose = "";
  String onConnect = "";
  String onDisconnect = "";
  String onFocus = "";
  String onHUDClick = "";
  String onKeyUp = "";
  String onOpen = "";
  String onResponse = "";
  String onSubneg = "";
  String type = "";
  ScriptInfo.fromJson(Map<String, dynamic> json) {
    desc = json['Desc'] ?? "";
    id = json['ID'] ?? "";
    intro = json['Intro'] ?? "";
    onAssist = json['OnAssist'] ?? "";
    onBroadCast = json['OnBroadCast'] ?? "";
    onBuffer = json['OnBuffer'] ?? "";
    onBufferMax = json['OnBufferMax'] ?? 0;
    onBufferMin = json['OnBufferMin'] ?? 0;
    onClose = json['OnClose'] ?? "";
    onConnect = json['OnConnect'] ?? "";
    onDisconnect = json['OnDisconnect'] ?? "";
    onFocus = json['OnFocus'] ?? "";
    onHUDClick = json['OnHUDClick'] ?? "";
    onKeyUp = json['OnKeyUp'] ?? "";
    onResponse = json['OnResponse'] ?? "";
    onSubneg = json['OnSubneg'] ?? "";
    type = json['Type'] ?? "";
  }
}

class ScriptInfoList {
  List<ScriptInfo> list = [];
  ScriptInfoList.fromJson(dynamic json) {
    list = List<dynamic>.from(json).map((e) => ScriptInfo.fromJson(e)).toList();
  }
}

class ScriptSettings {
  ScriptSettings();
  String channel = '';
  String desc = '';
  String intro = '';
  String name = '';
  String onAssist = '';
  String onBroadcast = '';
  String onBuffer = '';
  int onBufferMax = 0;
  int onBufferMin = 0;
  String onClose = '';
  String onConnect = '';
  String onDisconnect = '';
  String onFocus = '';
  String onHUDClick = '';
  String onKeyUp = '';
  String onOpen = '';
  String onResponse = '';
  String onSubneg = '';
  String type = '';
  ScriptSettings.fromJson(Map<String, dynamic> json) {
    channel = json['Channel'];
    desc = json['Desc'];
    intro = json['Intro'];
    name = json['Name'];
    onAssist = json['OnAssist'];
    onBroadcast = json['OnBroadcast'];
    onBuffer = json['OnBuffer'];
    onBufferMax = json['OnBufferMax'];
    onBufferMin = json['OnBufferMin'];
    onClose = json['OnClose'];
    onConnect = json['OnConnect'];
    onDisconnect = json['OnDisconnect'];
    onFocus = json['OnFocus'];
    onHUDClick = json['OnHUDClick'];
    onKeyUp = json['OnKeyUp'];
    onOpen = json['OnOpen'];
    onResponse = json['OnResponse'];
    onSubneg = json['OnSubneg'];
    type = json['Type'];
  }
}

class UpdateScriptSettingsForm extends ScriptSettings {
  String id = "";
  UpdateScriptSettingsForm();
  Map<String, dynamic> toJson() => {
        'Channel': channel,
        'Desc': desc,
        'Intro': intro,
        'Name': name,
        'OnAssist': onAssist,
        'OnBroadcast': onBroadcast,
        'OnBuffer': onBuffer,
        'OnBufferMax': onBufferMax,
        'OnBufferMin': onBufferMin,
        'OnClose': onClose,
        'OnConnect': onConnect,
        'OnDisconnect': onDisconnect,
        'OnFocus': onFocus,
        'OnHUDClick': onHUDClick,
        'OnKeyUp': onKeyUp,
        'OnOpen': onOpen,
        'OnResponse': onResponse,
        'OnSubneg': onSubneg,
        'Type': type,
        'ID': id,
      };
}

class RequiredParam {
  RequiredParam({required this.name, required this.intro, required this.desc});
  String name = "";
  String intro = "";
  String desc = "";
  RequiredParam.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    intro = json['Intro'];
    desc = json['Desc'];
  }
  Map<String, dynamic> toJson() => {
        "Name": name,
        "Intro": intro,
        "Desc": desc,
      };
}

class ParamsInfo {
  Map<String, String> paramComments = {};
  Map<String, String> params = {};
  List<RequiredParam> requiredParams = [];
  ParamsInfo.fromJson(Map<String, dynamic> json) {
    paramComments = Map<String, dynamic>.from(json['ParamComments'])
        .map((key, value) => MapEntry(key, value as String));
    params = Map<String, dynamic>.from(json['Params'])
        .map((key, value) => MapEntry(key, value as String));
    if (json['RequiredParams'] != null) {
      requiredParams = List<dynamic>.from(json['RequiredParams'])
          .map((e) => RequiredParam.fromJson(e))
          .toList();
    }
  }
}

class RequiredParams {
  List<RequiredParam> list = [];
  RequiredParams.fromJson(dynamic json) {
    if (json != null) {
      list = List<dynamic>.from(json)
          .map((e) => RequiredParam.fromJson(e))
          .toList();
    }
  }
  dynamic toJson() {
    return list.map((e) => e.toJson()).toList();
  }
}

class UpdateRequiredParams {
  UpdateRequiredParams({required this.current, required this.params});
  final String current;
  final RequiredParams params;
  Map<String, dynamic> toJson() => {
        'Current': current,
        'RequiredParams': params.toJson(),
      };
}
