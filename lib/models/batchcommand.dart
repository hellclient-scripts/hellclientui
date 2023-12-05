class BatchCommand {
  BatchCommand();
  String name = '';
  List<String> scripts = [];
  String command = '';
  BatchCommand.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    command = json['command'] ?? '';
    if (json['scripts'] != null) {
      scripts =
          List<dynamic>.from(json['scripts']).map((e) => e as String).toList();
    }
  }
  Map<String, dynamic> toJson() => {
        'name': name,
        'command': command,
        'scripts': scripts.map((e) => e as dynamic).toList(),
      };
  BatchCommand clone() {
    return BatchCommand.fromJson(toJson());
  }
}
