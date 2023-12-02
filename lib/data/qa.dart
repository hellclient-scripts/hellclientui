class QA {
  QA(this.question, this.answer);
  final String question;
  final String answer;
}

final List<QA> appQAList = [
  QA('这个程序可以直接连接Mud吗？', '''
这个程序并不是Mud客户端，它是服务器版mud客户端的hellclient的管理客户端，只能连接到正常运行的hellclient客户端里
'''),
  QA('Hellclient有网页界面，这个程序的用处是？', '''
hellclient的网页版具有完整的功能。
本客户端的主要功能为
1.管理多个hc服务器端的信息，并快速连接
2.更好的渲染性能
3.由于不受浏览器限制，可以更方便的使用各种手势。
4.可以集成通知功能
5.可以自定义色彩
'''),
];
