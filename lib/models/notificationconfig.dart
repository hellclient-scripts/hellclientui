class NotificationConfig {
  NotificationConfig();
  bool desktopNotificationDisabled = false;
  bool tencentEnabled = false;
  String tencentAccessID = "";
  String tencentAccessKey = "";
  NotificationConfig.fromJson(Map<String, dynamic> json)
      : desktopNotificationDisabled =
            json['desktopNotificationDisabled'] ?? false,
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
