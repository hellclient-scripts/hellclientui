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
  QA('为什么我觉得这个程序操作不是很顺手？', '''
这个程序是使用跨平台框架flutter开发的。
一套代码同时会发布手机版和桌面版。
所以在操作会有所妥协，尽量使得手机和桌面端都能用一套逻辑进行操作。
'''),
  QA('我怎么备份程序的设置？', '''
程序的设置分为两个文件。分别是显示设置的colors.json和其他设置settings.json。
在桌面版，这两个文件的位置在可执行文件的文件夹内。
在安卓端，这两个文件的位置在应用程序数据内。
在设置中有导入导出栏目，可以以配置字符串的形式进行设置的备份和分享。
'''),
  QA('什么是长链接?', '''
长链接是hellclient提供的一种功能扩展机制。除了独占的进行UI操作/ws链接外，hellclient还提供了可以被多个程序连接的/messager链接，与脚本进行功能交互。长链接就是一直保持这种功能扩展连接，获取最实时的双向信息。
'''),
  QA('我怎么利用脚本推送桌面通知？', '''推送桌面通知十分简单，只需要客户端内对应服务器选择保持长连接，然后客户端执行
/Request('desktopnotification',JSON.stringify({Title:'推送标题',Body:'推送正文'}))
即可。
'''),
  QA('什么是批量命令?',
      '''批量命令是方便维护，将同一个指令输入到所有服务器的所有游戏里批量执行。可以通过服务器设置有游戏设置来无视批量指令。批量指令需要指定发送的脚本，避免游戏无法识别指令。
'''),
  QA('客户端各平台的支持怎么样？',
      '''安卓和Linux桌面端由于是作者主力系统，是稳定性最高的平台。Windows桌面版会保证一定的稳定性。Mac桌面版和iOS有不稳定体验版。
      '''),
  QA('缩放比例取整是什么意思？',
      '''部分操作系统，主要是Windows,会使用非整数倍的缩放比例，导致渲染时有小数部分的宽度，在多个文字样式叠加后会导致文字符号无法在垂直方向对齐。开启该选项后会只进行整数倍的缩放，确保对齐效果，但可能造成非整数倍缩放时字体模糊。
      '''),
  QA('关闭输入的用处是什么？',
      '''部分系统比如iOS下，输入法占用过多界面空间，通过关闭和开启输入，可以手动控制是否能够输入，避免输入法影响体验''')
];
