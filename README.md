# FotoPlaceCinema
用 Swift 完美复刻足记App中的大片模式

A replica of 'Cinema Mode' in FotoPlace App, written in Swift

![Screenshot](https://raw.githubusercontent.com/DJBen/FotoPlaceCinema/master/FotoPlaceCinema.png)

## 灵感 Inspiration
最近足记这个App产生的各种“廉价电影特效”在中国各大社交网站上爆炸式增长。我于是花了两天一共8小时左右实现了一下，觉得无论是谁想出来的，这样的点子非常的棒。目前只实现了基本功能，有一些小毛病，没有实现的功能在下面的section中可以找到。欢迎对我不成熟的代码圈圈点点，本人还要向大神们多多指教。

FotoPlace app is quickly gaining influence over Chinese social networks due to its ability to create a movie screenshot-like photo with subtitles. This attempt is to implement the feature described using Swift. I only finished it within 8 hours that span two days, so there are lots of glitches and TODOs (see below). Any contributions / suggestions / comments are welcome.

## 怎样运行 How to Run
`pod install` -> open `*.xcworkspace` -> Press RUN button.

## 未完成列表
1. 从相册中选取照片。
2. 截图器视图的缩放支持。
3. 照相视图的旋转。
4. 编辑字幕的视图控制器。现在只是一个 `UIAlertController`。
5. 一键优化，添加滤镜，对比度，字幕可选项。
6. 照相视图的闪光灯和前后镜头切换支持。

## TODO
1. Choose photos from iphone gallery.
2. Zooming support of image cropper. Right now the image cropper can only be dragged, but cannot be zoomed.
3. The visual rotation of the photo capture VC when user holds the device in landscape, etc.
4. THe VC to edit subtitles. (Currently we have only an `UIAlertController`).
5. Some additional features implemented by FotoPlace but not present here regarding editing photos.
6. Flash light control, focus control and camera switching in photo capture VC.
