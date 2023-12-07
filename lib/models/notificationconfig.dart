class NotificationConfig {
  NotificationConfig();
  bool desktopNotificationDisabled = false;
  bool tencentEnabled = false;
  String audio = '';
  String tencentAccessID = "";
  String tencentAccessKey = "";
  NotificationConfig.fromJson(Map<String, dynamic> json)
      : desktopNotificationDisabled =
            json['desktopNotificationDisabled'] ?? false,
        audio = json['audio'] ?? '',
        tencentEnabled = json['tencentEnabled'],
        tencentAccessID = json['tencentAccessID'],
        tencentAccessKey = json['tencentAccessKey'];
  Map<String, dynamic> toJson() => {
        'desktopNotificationDisabled': desktopNotificationDisabled,
        'tencentEnabled': tencentEnabled,
        'tencentAccessID': tencentAccessID,
        'tencentAccessKey': tencentAccessKey,
      };
}
