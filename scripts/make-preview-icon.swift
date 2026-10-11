import AppKit

// Original artwork for Textline Preview: a sheet of text on a blue tile.
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()
NSColor(calibratedRed: 0.12, green: 0.24, blue: 0.42, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 40, y: 40, width: 944, height: 944), xRadius: 205, yRadius: 205).fill()
NSColor(calibratedRed: 0.06, green: 0.14, blue: 0.27, alpha: 0.6).setFill()
NSBezierPath(roundedRect: NSRect(x: 258, y: 162, width: 556, height: 658), xRadius: 60, yRadius: 60).fill()
NSColor(calibratedRed: 0.98, green: 0.98, blue: 0.94, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 226, y: 196, width: 556, height: 658), xRadius: 60, yRadius: 60).fill()
NSColor(calibratedRed: 0.12, green: 0.24, blue: 0.42, alpha: 1).setFill()
for (y, width) in [(658.0, 380.0), (536.0, 380.0), (414.0, 264.0)] {
    NSBezierPath(roundedRect: NSRect(x: 314, y: y, width: width, height: 46), xRadius: 23, yRadius: 23).fill()
}
NSColor(calibratedRed: 0.22, green: 0.79, blue: 0.70, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 436, y: 782, width: 136, height: 120), xRadius: 36, yRadius: 36).fill()
image.unlockFocus()
guard CommandLine.arguments.count == 2,
      let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Usage: swift make-preview-icon.swift OUTPUT.png")
}
try png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
