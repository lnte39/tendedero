> This fork adds opt-in plain-text clipboard cards. Build **Textline Preview**
> using the [fork build steps](#build-from-source); it has its own name, icon,
> settings and storage. The screenshots below show the upstream app.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/hero-dark.png">
  <img src="docs/images/hero-light.png" alt="Tendedero. Screenshots, hung out to dry. Three screenshots in glass frames hang from a thin line under the macOS menu bar.">
</picture>

<h3 align="center"><a href="https://tendedero.app/?lang=en">Try it in your browser at tendedero.app&nbsp;&rsaquo;</a></h3>

<p align="center">
  Free and open source. For macOS 14 and later.
  <br>
  <a href="../../releases/latest">Download&nbsp;&rsaquo;</a>
  &nbsp;&nbsp;
  <a href="#build-from-source">Build from source&nbsp;&rsaquo;</a>
  <br><br>
  English&nbsp;·&nbsp;<a href="docs/i18n/README.es.md">Español</a>&nbsp;·&nbsp;<a href="docs/i18n/README.fr.md">Français</a>&nbsp;·&nbsp;<a href="docs/i18n/README.pt-BR.md">Português (Brasil)</a>&nbsp;·&nbsp;<a href="docs/i18n/README.ja.md">日本語</a>&nbsp;·&nbsp;<a href="docs/i18n/README.ko.md">한국어</a>&nbsp;·&nbsp;<a href="docs/i18n/README.zh-Hans.md">简体中文</a>
</p>

<br>

## Out of sight. Within reach.

Every screenshot you take hangs on a line just above your screen.
Rest the pointer in the menu bar and it glides down. Move away and it's gone.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-dark.gif">
  <img src="docs/images/demo-light.gif" alt="The pointer rests against the top edge, the line slides down with three screenshots swinging gently, a click copies one, and the line tucks away when the pointer leaves.">
</picture>

<br>
<br>

## A gesture for everything.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/bento-dark.png">
  <img src="docs/images/bento-light.png" alt="Click to copy. Hold to mark up. Drag to share. Let it go.">
</picture>

<br>
<br>

| | |
|:--|:--|
| Click | Copy the image. |
| Press and hold | Open it in Markup. |
| Double click | Open it in Preview. |
| Force click | Take a quick look. |
| Drag into an app | Send a copy. It stays on the line. |
| Drag into a folder | Keep it there. It leaves the line. |
| Drag to the Trash, or click the cross | Let it go. |
| Rest the pointer in the menu bar | Bring the line down on that screen. |
| Click anything in the menu bar | Put it away. |
| <kbd>⌃</kbd>&thinsp;<kbd>⌥</kbd>&thinsp;<kbd>T</kbd> | Show or hide the line. Change it under Shortcut in the menu bar. |

<br>

## Your Desktop. Finally clear.

Hand Tendedero your screenshots<sup>1</sup> and they skip the Desktop
entirely. No floating thumbnail. No five-second wait. Each capture hangs
the instant you take it, and only what you drag out is kept.

Screen recordings hang there too, with a play button over them.
Press and hold one to trim it.

Same shortcuts. Same muscle memory. Just less mess.

<br>

## Copied images too.

Take a screenshot with <kbd>⌃</kbd> held, or copy an image in Preview, and it
hangs on the line like any other. Turn on Hang copied images in the menu bar
and the shirt fills in while it is on. Only images: anything copied along
with text or a file, and anything a password manager marks as private, is
left alone.

<br>

## Plain text in this fork

Turn on **Hang copied text** in the menu bar to keep new copied text on the
line. This switch is off by default and is independent of **Hang copied
images**. Enabling it never imports what is already on the clipboard.

- Click a text card to copy its complete plain text, including whitespace,
  line breaks, Unicode and emoji. Only the card preview is shortened.
- Long press or force click to Quick Look; double click to open the `.txt`
  file in your default text editor. Dragging shares or moves that file using
  the existing file gestures. Text does not offer image Markup.
- Text shares the line's capacity and restart persistence with screenshots.
  Turning the switch off stops capture; it does not erase existing cards.
- The plain representation of rich text is accepted; formatting is not
  retained. File copies, private/temporary/automatically generated copies,
  multiple-item text copies, empty text, NUL-containing text and text over
  1 MiB in UTF-8 are skipped. There is no OCR.
- Text is stored locally as owner-only UTF-8 files in the app's inbox.
  Text content is never put in filenames or logs. As with screenshots,
  discarded or expired inbox items go to the Trash, which retains them
  until you empty it. Unmarked sensitive text can still be captured;
  keep the switch off when copying content you do not want saved.

Development tests: `bash scripts/check-text.sh` uses only synthetic content, private named
pasteboards, temporary files and isolated preferences. It does not launch
the app or inspect the general clipboard. Windows is not supported by this change.

## Private by design.

No account. No network. No analytics.
Tendedero runs entirely on your Mac, and your screenshots never leave it.

<br>

## Upstream Tech Specs

The preview is built for the host architecture and has been verified on Apple silicon.

| | |
|:--|:--|
| **Compatibility** | macOS 14 Sonoma or later, on Apple silicon and Intel. Designed for macOS 27. |
| **Size** | 1.7 MB |
| **Languages** | English, Spanish, French, Portuguese (Brazil), Japanese, Korean, Chinese (Simplified), Turkish, Azerbaijani |
| **Built with** | Swift, AppKit and SwiftUI |
| **Network access** | None |
| **Price** | Free |
| **License** | MIT for the code. The name and icon are not included. |

<br>

## Install the upstream app

The upstream release does not include this fork's text support. For the fork,
use the source build below.

Download the upstream disk image from the [latest release](https://github.com/alejandrobujan/tendedero/releases/latest),
open it and drag Tendedero to Applications. Or install it with Homebrew:

```sh
brew install --cask alejandrobujan/tap/tendedero
```

Tendedero is signed with a Developer ID and notarized by Apple, so it opens
like any other app.

<br>

## Build from source

```sh
git clone https://github.com/lnte39/tendedero.git
cd tendedero
bash scripts/build-preview.sh "$PWD/build"
open "build/Textline Preview.app"
```

Requires macOS 14 or later and a compatible Swift toolchain/SDK. Xcode is
optional. The preview is built for the host architecture and signed locally
ad hoc, without a Developer ID or notarization. It starts with clipboard
monitoring off and refuses to replace an existing output app. See the
[acceptance steps](docs/textline-preview.md) and
[validation commands](docs/text-support-validation.md).

Use this preview script for modified builds: the unchanged upstream
`build-app.sh` still uses the upstream name and icon.

<details>
<summary>Inside the app</summary>
<br>

| File | Role |
|:--|:--|
| `AppDelegate.swift` | Menu bar, shortcut, revealing and tucking away the line |
| `LinePanel.swift` | The transparent strip along the top of the screen |
| `LineView.swift` | The line and where each photo hangs |
| `PeggedView.swift` | One photo: glass frame, clip, swing and breeze |
| `GrabArea.swift` | Click, long press, drag and drop |
| `ScreenshotWatcher.swift` | Notices new screenshots |
| `ClipboardWatcher.swift` | Notices opt-in image and plain-text clipboard copies |
| `TextClipping.swift` | Stores, previews and copies exact UTF-8 text |
| `AppIdentity.swift` | Keeps the preview name and storage separate |
| `Inbox.swift` | Takes over screenshot settings and puts them back |
| `Markup.swift` | Opens the system Markup editor and saves the result |
| `Trim.swift` | Trims a screen recording and saves the result |
| `FullScreen.swift` | Knows when to stay hidden |
| `Line.swift` | What is hanging, and what you can do with it |

Every image here, the icon included, is drawn in code by
`scripts/make-icon.swift` and `scripts/make-readme-art.swift`.
`scripts/make-dmg.sh` builds the disk image for releases.

Translations live in `Sources/Tendedero/Resources`, one `.lproj` folder per
language. `swift scripts/check-strings.swift` checks that none is missing.

</details>

<br>

---

<sub>
1. On first launch, Tendedero offers to handle your screenshots. If you accept, it turns off the floating thumbnail and saves new screenshots to its own folder, two settings also found under Options in Cmd+Shift+5. Your previous settings are saved and restored when Tendedero quits or the option is turned off from the menu bar. Tendedero hides automatically while an app is in full screen.
</sub>

<br>
<br>

<p align="center">
  <img src="docs/images/icon.png" width="64" height="64" alt="">
  <br>
  <sub>The code is MIT licensed. The Tendedero name and icon are not, so forks need their own. See <a href="LICENSE">LICENSE</a>.</sub>
  <br>
  <sub>Designed and built by <a href="https://alejandrobujan.com">Alejandro Buján</a>.</sub>
</p>
