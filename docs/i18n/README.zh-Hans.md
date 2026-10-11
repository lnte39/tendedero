> 此 fork 新增默认关闭的纯文字剪贴板卡片。请按下方“从源码构建”生成
> **Textline Preview**，它使用独立名称、图标、设置和保存目录；下方截图来自原版。

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../images/zh-Hans/hero-dark.png">
  <img src="../images/zh-Hans/hero-light.png" alt="Tendedero。截图挂起来晾着。三张截图装在玻璃相框里，挂在 macOS 菜单栏下方的一根细绳上。">
</picture>

<h3 align="center"><a href="https://tendedero.app/?lang=zh-Hans">在 tendedero.app 上直接用浏览器试用&nbsp;&rsaquo;</a></h3>

<p align="center">
  免费开源。适用于 macOS 14 及以上。
  <br>
  <a href="../../../../releases/latest">下载&nbsp;&rsaquo;</a>
  &nbsp;&nbsp;
  <a href="#从源码构建">从源码构建&nbsp;&rsaquo;</a>
  <br><br>
  <a href="../../README.md">English</a>&nbsp;·&nbsp;<a href="README.es.md">Español</a>&nbsp;·&nbsp;<a href="README.fr.md">Français</a>&nbsp;·&nbsp;<a href="README.pt-BR.md">Português (Brasil)</a>&nbsp;·&nbsp;<a href="README.ja.md">日本語</a>&nbsp;·&nbsp;<a href="README.ko.md">한국어</a>&nbsp;·&nbsp;简体中文
  <br>
  <sub>本文译自英文 README。如有出入，以英文版为准。</sub>
</p>

<br>

## 看不见，却够得着

你每截一张图，它都会挂到屏幕顶上的一根绳上。
把指针停在菜单栏，绳子就滑下来；移开，它就收起。

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../images/zh-Hans/demo-dark.gif">
  <img src="../images/zh-Hans/demo-light.gif" alt="指针停在上边缘，绳子带着三张截图轻轻摇晃着滑下来，单击复制其中一张，指针离开后绳子收起。">
</picture>

<br>
<br>

## 每个动作都有手势

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../images/zh-Hans/bento-dark.png">
  <img src="../images/zh-Hans/bento-light.png" alt="单击复制。长按标记。拖拽分享。松手放下。">
</picture>

<br>
<br>

| | |
|:--|:--|
| 单击 | 复制这张图。 |
| 长按 | 用「标记」打开。 |
| 双击 | 用「预览」打开。 |
| 用力点按 | 用「快速查看」看一眼。 |
| 拖进 App | 送一份副本过去。原图仍挂在绳上。 |
| 拖进文件夹 | 存在那儿。原图从绳上取下。 |
| 拖到废纸篓，或点叉 | 松手丢弃。 |
| 指针停在菜单栏 | 在那一块屏幕上放下绳子。 |
| 点击菜单栏任意处 | 把绳子收起来。 |
| <kbd>⌃</kbd>&thinsp;<kbd>⌥</kbd>&thinsp;<kbd>T</kbd> | 显示或隐藏绳子。可在菜单栏的「快捷键」中更改。 |

<br>

## 桌面，终于清爽了

把截图交给 Tendedero<sup>1</sup>，它们就完全跳过桌面。
没有浮动缩略图。不用等五秒。拍下的瞬间即挂上绳，只有你拖出去的才会留下。

屏幕录制也会挂上绳，上面带一个播放按钮。按住即可剪辑。

同样的快捷键。同样的肌肉记忆。只是少了乱。

<br>

## 复制的图片也一样

按住 <kbd>⌃</kbd> 截图，或在「预览」中复制图片，它就会像其他截图一样挂上绳。
在菜单栏中打开「挂上复制的图片」，开启期间图标里的衬衫会被填满。只挂图片：
与文字或文件一起复制的内容，以及密码管理器标为私密的内容，都不会被挂上。

<br>

## 隐私是设计前提

没有账号。不联网。无统计。
Tendedero 完全在你的 Mac 上运行，截图不会离开这台电脑。

<br>

## 原版技术规格

本 fork 的预览版按本机架构构建，目前只在 Apple silicon 上验证。

| | |
|:--|:--|
| **兼容性** | macOS 14 Sonoma 及以上，Apple 芯片与 Intel 均支持。已针对 macOS 27 设计。 |
| **体积** | 1.7 MB |
| **语言** | 英语、西班牙语、法语、巴西葡萄牙语、日语、韩语、简体中文、土耳其语、阿塞拜疆语 |
| **技术栈** | Swift、AppKit 与 SwiftUI |
| **网络访问** | 无 |
| **价格** | 免费 |
| **许可** | 代码为 MIT。名称与图标不在授权范围内。 |

<br>

## 安装原版

原版发布不包含此 fork 的文字支持；此 fork 请按下方步骤从源码构建。

从[最新发布](https://github.com/alejandrobujan/tendedero/releases/latest)下载磁盘映像，打开后把 Tendedero 拖进「应用程序」。也可以用 Homebrew 安装：

```sh
brew install --cask alejandrobujan/tap/tendedero
```

Tendedero 已使用 Developer ID 签名并通过 Apple 公证，打开方式和其他 App 一样。

<br>

## 从源码构建

```sh
git clone https://github.com/lnte39/tendedero.git
cd tendedero
bash scripts/build-preview.sh "$PWD/build"
open "build/Textline Preview.app"
```

需要 macOS 14 或以上及兼容的 Swift 工具链/SDK，Xcode 可选。预览版按本机架构构建，采用本地 ad-hoc 签名，未做公证。剪贴板监测默认关闭，脚本拒绝覆盖已有输出应用。修改版请使用此预览脚本；上游的 `build-app.sh` 仍使用原版名称和图标。

<details>
<summary>应用内部</summary>
<br>

| 文件 | 作用 |
|:--|:--|
| `AppDelegate.swift` | 菜单栏、快捷键、放下与收起绳子 |
| `LinePanel.swift` | 屏幕顶部那条透明的窄条 |
| `LineView.swift` | 绳子本身，以及每张照片挂在哪里 |
| `PeggedView.swift` | 一张照片：玻璃相框、夹子、摇摆与微风 |
| `GrabArea.swift` | 单击、长按、拖放 |
| `ScreenshotWatcher.swift` | 发现新的截图 |
| `Inbox.swift` | 接管截图设置，之后再把它们放回去 |
| `ClipboardWatcher.swift` | 发现复制到剪贴板的图片 |
| `Markup.swift` | 打开系统「标记」编辑器并保存结果 |
| `Trim.swift` | 剪辑屏幕录制并保存结果 |
| `FullScreen.swift` | 判断何时该保持隐藏 |
| `Line.swift` | 绳上挂着什么，以及你能对它做什么 |

这里出现的每一张图——包括图标——都是由代码绘制的：
`scripts/make-icon.swift` 与 `scripts/make-readme-art.swift`。
`scripts/make-dmg.sh` 负责构建发布用的磁盘映像。

翻译文件位于 `Sources/Tendedero/Resources`，每种语言一个 `.lproj` 文件夹。
`swift scripts/check-strings.swift` 会检查是否有遗漏。

</details>

<br>

---

<sub>
1. 首次启动时，Tendedero 会询问是否接管你的截图。如果同意，它会关闭浮动缩略图，并把新截图保存到它自己的文件夹，这两项设置也可以在 Cmd+Shift+5 的「选项」中找到。你原来的设置会被保存，并在退出 Tendedero 或从菜单栏关闭该选项时恢复。当有 App 处于全屏时，Tendedero 会自动隐藏。
</sub>

<br>
<br>

<p align="center">
  <img src="../images/icon.png" width="64" height="64" alt="">
  <br>
  <sub>代码采用 MIT 许可。Tendedero 这一名称与图标不在许可范围内，因此 fork 需要自备名称与图标。详见 <a href="../../LICENSE">LICENSE</a>。</sub>
  <br>
  <sub>由 <a href="https://alejandrobujan.com">Alejandro Buján</a> 设计与开发。</sub>
</p>


## 此 fork 新增：复制文字

在菜单栏开启 **挂上复制的文字** 后，新复制的文字会挂到晾衣绳上。
它默认关闭，与图片开关相互独立；开启时不会导入剪贴板中已有的内容。

- 单击卡片复制完整原文，保留中文、emoji、空格和换行；卡片只显示摘要。
- 长按或用力点按可快速查看，双击用默认文本编辑器打开；拖动传递的是 `.txt` 文件。
- 文字与截图共用保留数量，重启后恢复。关闭文字开关只停止接收，不删除已有条目。
- 富文本仅保留纯文字。文件复制、标记为私密/临时/自动生成的内容、多条目复制、空字符串、含 NUL 的文本和超过 1 MiB UTF-8 的文本会跳过；没有 OCR。
- 文字只保存在本机，文件仅当前用户可读，文件名和日志不含正文。丢弃或超出保留数量的条目进入废纸篓，清空废纸篓前仍可恢复。未标记的敏感文字也可能被接收，需要时请关闭此开关。

`bash scripts/check-text.sh` 仅使用合成内容、独立测试剪贴板、临时文件和独立偏好设置，不启动应用、不读取通用剪贴板。本次改动不包含 Windows 支持。

### 独立本机验收包

此 fork 可用 `bash scripts/build-preview.sh /绝对路径/输出目录` 打包
**Textline Preview.app**。它使用独立名称、原创图标、设置域和保存目录，
两个剪贴板开关默认关闭，且拒绝覆盖已有输出应用。请查看
[验收步骤](../textline-preview.md)和[验证报告](../text-support-validation.md)。
