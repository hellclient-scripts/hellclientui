# hellclientui

基于flutter开发的跨平台hellclient控制界面。

本身不带有连接MUD服务的功能，需要连接到运行中的[hellclient](https://github.com/jarlyyn/hellclient) 服务。

主要作用是可以方便的连接多个hellclient终端，可以对连接界面有一定的自定义，界面渲染显示效果也更好。

支持的平台包括
* Windows
* Linux
* Mac os x\(试验性支持\) [Appstore 中查看](https://apps.apple.com/app/hellclient-ui/id6502743040)
* Android
* iOS [Appstore 中查看](https://apps.apple.com/app/hellclient-ui/id6502743040)

## 社区支持

访问[Hellclient社区](http://forum.hellclient.com)获得社区支持。

## 常见问题

### Windows版报错 “由于找不到 VCRUNTIME140_1.dll,无法继续执行代码，重新安装程序可能会解决此问题。”

需要下载安装微软的VC的运行时库。

官方下载地址为

https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170

也可以使用其他可信任的地方下载的库。