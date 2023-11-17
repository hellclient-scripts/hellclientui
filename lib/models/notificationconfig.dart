class NotificationConfig {
  NotificationConfig();
  bool tencentEnabled = false;
  String tencentAccessID = "";
  String tencentAccessKey = "";
  NotificationConfig.fromJson(Map<String, dynamic> json)
      : tencentEnabled = json['tencentEnabled'],
        tencentAccessID = json['tencentAccessID'],
        tencentAccessKey = json['tencentAccessKey'];
  Map<String, dynamic> toJson() => {
        'tencentEnabled': tencentEnabled,
        'tencentAccessID': tencentAccessID,
        'tencentAccessKey': tencentAccessKey,
      };
}
