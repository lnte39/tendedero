import AppKit

/// Plain UTF-8 files let text use the same retention, restore and file drag
/// behavior as screenshots. Only the card preview is shortened.
enum TextClipping {
    static let maxBytes = 1024 * 1024
    static let copiedType = NSPasteboard.PasteboardType("app.tendedero.copied-text")

    static func isText(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == "txt"
    }

    static func accepts(_ text: String) -> Bool {
        !text.isEmpty && !text.utf8.contains(0) && text.utf8.count <= maxBytes
    }

    static func read(_ url: URL) -> String? {
        guard let file = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? file.close() }
        guard let data = try? file.read(upToCount: maxBytes + 1),
              data.count <= maxBytes,
              let text = String(data: data, encoding: .utf8), accepts(text) else { return nil }
        return text
    }

    /// No text goes into the filename or logs. Create the file owner-only
    /// from the start, rather than tightening its permissions after writing.
    static func save(_ text: String, in folder: URL) throws -> URL {
        guard accepts(text) else { throw CocoaError(.fileWriteInapplicableStringEncoding) }
        let fm = FileManager.default
        try fm.createDirectory(at: folder, withIntermediateDirectories: true,
                               attributes: [.posixPermissions: 0o700])
        let url = folder.appendingPathComponent("Text \(UUID().uuidString).txt")
        let fd = open(url.path, O_WRONLY | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR)
        guard fd >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        let file = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
        do {
            try file.write(contentsOf: Data(text.utf8))
            try file.close()
            return url
        } catch {
            try? file.close()
            try? fm.removeItem(at: url)
            throw error
        }
    }

    /// Deliberately offers text, not its backing file, when clicked. The
    /// marker prevents the watcher from hanging our own copy again.
    static func pasteboardItem(for url: URL) -> NSPasteboardItem? {
        guard let text = read(url) else { return nil }
        let item = NSPasteboardItem()
        item.setString(text, forType: .string)
        item.setData(Data(), forType: copiedType)
        return item
    }

    static func thumbnail(_ url: URL, maxPixels: Int) -> NSImage? {
        guard let text = read(url) else { return nil }
        let preview = String(text.prefix(2048))
        let width = CGFloat(max(1, maxPixels))
        let size = NSSize(width: width, height: width * 0.72)
        return NSImage(size: size, flipped: true) { rect in
            NSColor(calibratedRed: 1, green: 0.98, blue: 0.90, alpha: 1).setFill()
            rect.fill()
            let scale = width / 320
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byWordWrapping
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 26 * scale),
                .foregroundColor: NSColor(calibratedWhite: 0.16, alpha: 1),
                .paragraphStyle: paragraph,
            ]
            (preview as NSString).draw(
                with: rect.insetBy(dx: 22 * scale, dy: 22 * scale),
                options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                attributes: attributes)
            return true
        }
    }
}
