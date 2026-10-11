import AppKit

/// Every test owns a named pasteboard, temporary files and a preferences
/// suite. None reads or writes the general clipboard or starts the app.
@MainActor
final class ClipboardChecks {
    @MainActor
    private final class Fixture {
        let folder: URL
        let pasteboard: NSPasteboard
        let defaults: UserDefaults
        let suite = "TendederoTests.\(UUID().uuidString)"

        init() throws {
            folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            pasteboard = NSPasteboard(name: .init("TendederoTests.\(UUID().uuidString)"))
            defaults = UserDefaults(suiteName: suite)!
            defaults.set(true, forKey: "soundOff")
        }

        func cleanUp() {
            pasteboard.releaseGlobally()
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: folder)
        }

        func put(_ text: String, extraTypes: [NSPasteboard.PasteboardType] = []) {
            let item = NSPasteboardItem()
            Check.that(item.setString(text, forType: .string))
            for type in extraTypes { Check.that(item.setData(Data(), forType: type)) }
            pasteboard.clearContents()
            Check.that(pasteboard.writeObjects([item]))
        }

        func line() -> Line {
            // Files in these tests are external to the inbox, so eviction
            // never touches even the user's Trash.
            Line(defaults: defaults, inboxFolder: folder.appendingPathComponent("inbox"), breeze: false)
        }
    }

    private func png() throws -> Data {
        let rep = try Check.unwrap(NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 2, pixelsHigh: 2,
                                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                               isPlanar: false, colorSpaceName: .deviceRGB,
                                               bytesPerRow: 0, bitsPerPixel: 0))
        let pixels = try Check.unwrap(rep.bitmapData)
        for y in 0..<2 { for x in 0..<2 {
            let offset = y * rep.bytesPerRow + x * 4
            pixels[offset] = 255; pixels[offset + 1] = 64
            pixels[offset + 2] = 32; pixels[offset + 3] = 255
        } }
        return try Check.unwrap(rep.representation(using: .png, properties: [:]))
    }

    func testStartsOptedOutAndOnlyCapturesNewTextAfterEnabling() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        var saved: [URL] = []
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { saved.append($0) }
        defer { watcher.stop() }
        watcher.start(images: false, text: false)
        f.put("before enabling"); watcher.check()
        Check.that(saved.isEmpty)
        watcher.start(images: false, text: true)
        watcher.check()
        Check.that(saved.isEmpty)
        f.put("new synthetic text"); watcher.check()
        Check.equal(saved.count, 1)
        Check.equal(TextClipping.read(try Check.unwrap(saved.first)), "new synthetic text")
        watcher.stop()
        f.put("after stopping"); watcher.check()
        Check.equal(saved.count, 1)
    }

    func testImageOnlyModeDoesNotCaptureText() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        var saved: [URL] = []
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { saved.append($0) }
        defer { watcher.stop() }
        watcher.start(images: true, text: false)
        f.put("text with image representation", extraTypes: [.png]); watcher.check()
        Check.that(saved.isEmpty)
    }

    func testRoundTripPreservesUTF8WhitespaceAndRestoresAfterRestart() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        let original = "  你好，世界 👩🏽‍💻\r\n\tCafe\u{301} / Café\nhttps://example.test/?a=1&b=2  \n"
        let line = f.line()
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { _ = line.hang($0, quietly: true) }
        defer { watcher.stop() }
        watcher.start(images: false, text: true)
        f.put(original); watcher.check()
        let item = try Check.unwrap(line.items.first)
        Check.that(item.isText)
        Check.isFalse(item.isRecording)
        Check.equal(try Data(contentsOf: item.url), Data(original.utf8))
        let attrs = try FileManager.default.attributesOfItem(atPath: item.url.path)
        Check.equal((attrs[.posixPermissions] as? NSNumber)?.intValue, 0o600)
        Check.isFalse(item.url.lastPathComponent.contains("你好"))
        let restored = f.line()
        Check.equal(restored.liveCount, 1)
        let restoredItem = try Check.unwrap(restored.items.first)
        restored.copy(restoredItem.id, to: f.pasteboard)
        Check.equal(f.pasteboard.string(forType: .string).map { Data($0.utf8) }, Data(original.utf8))
        Check.isNil(f.pasteboard.string(forType: .fileURL))
        Check.isNil(f.pasteboard.data(forType: .png))
        Check.equal(restored.copiedID, restoredItem.id)
        watcher.check()
        Check.equal(line.liveCount, 1, "Copying a card back must not add another card")
    }

    func testPrivacyAndFileMarkersAreRejectedOnAnyItem() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        var saved: [URL] = []
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { saved.append($0) }
        defer { watcher.stop() }
        watcher.start(images: true, text: true)
        let markers: [NSPasteboard.PasteboardType] = [
            .fileURL, .init("org.nspasteboard.ConcealedType"),
            .init("org.nspasteboard.TransientType"), .init("org.nspasteboard.AutoGeneratedType"),
            TextClipping.copiedType,
        ]
        for marker in markers {
            f.put("synthetic private text", extraTypes: [marker]); watcher.check()
            let publicItem = NSPasteboardItem(); publicItem.setString("public", forType: .string)
            let privateItem = NSPasteboardItem(); privateItem.setData(Data(), forType: marker)
            f.pasteboard.clearContents()
            Check.that(f.pasteboard.writeObjects([publicItem, privateItem]))
            watcher.check()
        }
        Check.that(saved.isEmpty)
        Check.that(try FileManager.default.contentsOfDirectory(atPath: f.folder.path).isEmpty)
    }

    func testRichTextUsesPlainRepresentationAndURLTextStaysText() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        var saved: [URL] = []
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { saved.append($0) }
        defer { watcher.stop() }
        watcher.start(images: true, text: true)
        f.put("plain part of rich text", extraTypes: [.rtf, .html, .png]); watcher.check()
        f.put("https://example.test", extraTypes: [.URL]); watcher.check()
        Check.equal(saved.compactMap(TextClipping.read), ["plain part of rich text", "https://example.test"])
        Check.that(saved.allSatisfy(TextClipping.isText))
    }

    func testMultipleTextItemsAreNotSilentlyJoined() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        var saved: [URL] = []
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { saved.append($0) }
        defer { watcher.stop() }
        watcher.start(images: false, text: true)
        let items = ["one", "two"].map { text -> NSPasteboardItem in
            let item = NSPasteboardItem(); item.setString(text, forType: .string); return item
        }
        f.pasteboard.clearContents(); Check.that(f.pasteboard.writeObjects(items)); watcher.check()
        Check.that(saved.isEmpty)
    }

    func testConsecutiveDuplicateIsSkippedButRemovedClippingCanReturn() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        var saved: [URL] = []
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { saved.append($0) }
        defer { watcher.stop() }
        watcher.start(images: false, text: true)
        f.put("duplicate"); watcher.check()
        f.put("duplicate"); watcher.check()
        Check.equal(saved.count, 1)
        try FileManager.default.removeItem(at: Check.unwrap(saved.first))
        f.put("duplicate"); watcher.check()
        Check.equal(saved.count, 2)
        f.put("é"); watcher.check()
        f.put("e\u{301}"); watcher.check()
        Check.equal(saved.count, 4, "Distinct UTF-8 must not be normalized during deduplication")
    }

    func testInvalidAndOversizedTextAreRejectedWithoutTruncatingAcceptedText() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        var saved: [URL] = []
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { saved.append($0) }
        defer { watcher.stop() }
        watcher.start(images: false, text: true)
        for text in ["", "a\0b", String(repeating: "x", count: TextClipping.maxBytes + 1),
                     String(repeating: "中", count: TextClipping.maxBytes / 3 + 1)] {
            f.put(text); watcher.check()
        }
        Check.that(saved.isEmpty)
        let limit = String(repeating: "x", count: TextClipping.maxBytes)
        f.put(limit); watcher.check()
        Check.equal(TextClipping.read(try Check.unwrap(saved.first)), limit)
        f.put(" \t\n"); watcher.check()
        Check.equal(TextClipping.read(try Check.unwrap(saved.last)), " \t\n")
    }

    func testInvalidBackingFileCannotBeRestoredOrClearClipboard() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        let url = try TextClipping.save("valid", in: f.folder)
        let line = f.line()
        let id = try Check.unwrap(line.hang(url, quietly: true))
        try Data([0xff, 0xfe]).write(to: url)
        Check.isNil(TextClipping.read(url))
        Check.equal(f.line().liveCount, 0)
        f.put("leave this synthetic clipboard alone")
        let count = f.pasteboard.changeCount
        line.copy(id, to: f.pasteboard)
        Check.equal(f.pasteboard.changeCount, count)
        Check.isNil(line.copiedID)
        try FileManager.default.removeItem(at: url)
        line.copy(id, to: f.pasteboard)
        Check.equal(f.pasteboard.changeCount, count)
    }

    func testCapacityAndRestoreKeepImagesAndTextInOrder() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        let imageURL = f.folder.appendingPathComponent("synthetic.png")
        try png().write(to: imageURL)
        let textURL = try TextClipping.save("first text", in: f.folder)
        let newestURL = try TextClipping.save("newest", in: f.folder)
        let line = f.line(); line.maxItems = 2
        Check.notNil(line.hang(imageURL, quietly: true))
        Check.notNil(line.hang(textURL, quietly: true))
        Check.equal(f.line().items.map(\.url), [imageURL, textURL])
        Check.notNil(line.hang(newestURL, quietly: true))
        Check.equal(line.liveCount, 2)
        Check.equal(f.line().items.map(\.url), [textURL, newestURL])
        Check.that(FileManager.default.fileExists(atPath: imageURL.path))
        line.reloadThumbnails()
        let newest = try Check.unwrap(line.items.last)
        line.discard(newest.id, quietly: true)
        Check.equal(f.line().items.map(\.url), [textURL])
    }

    func testImageCaptureAndCopyStillOfferPNGAndFileURL() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        let captured = Signal()
        let line = f.line()
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) {
            _ = line.hang($0, quietly: true); captured.fulfill()
        }
        defer { watcher.stop() }
        watcher.start(images: true, text: true)
        let original = try png()
        f.pasteboard.clearContents(); f.pasteboard.setData(original, forType: .png); watcher.check()
        await captured.wait(timeout: 3)
        let item = try Check.unwrap(line.items.first)
        Check.isFalse(item.isText)
        line.copy(item.id, to: f.pasteboard)
        Check.equal(f.pasteboard.data(forType: .png), original)
        Check.equal(f.pasteboard.string(forType: .fileURL), item.url.absoluteString)
        watcher.check()
        Check.equal(line.liveCount, 1)
    }

    func testTextOnlyModeDoesNotCaptureImagesAndStopCancelsImageDecode() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        let unexpected = Signal()
        unexpected.isInverted = true
        let watcher = ClipboardWatcher(pasteboard: f.pasteboard, folder: f.folder) { _ in unexpected.fulfill() }
        defer { watcher.stop() }
        let data = try png()
        watcher.start(images: false, text: true)
        f.pasteboard.clearContents(); f.pasteboard.setData(data, forType: .png); watcher.check()
        watcher.start(images: true, text: true)
        f.pasteboard.clearContents(); f.pasteboard.setData(data, forType: .png); watcher.check()
        watcher.stop()
        await unexpected.wait(timeout: 0.3)
        Check.that(try FileManager.default.contentsOfDirectory(atPath: f.folder.path).isEmpty)
    }

    func testTextPreviewRendersWithoutChangingBackingText() async throws {
        let f = try Fixture(); defer { f.cleanUp() }
        let original = String(repeating: "合成预览 👩🏽‍💻\n", count: 400)
        let url = try TextClipping.save(original, in: f.folder)
        for size in [256, 320, 432] {
            let thumbnail = try Check.unwrap(makeThumbnail(url, maxPixels: size))
            Check.equal(thumbnail.size.width, CGFloat(size))
            Check.notNil(thumbnail.tiffRepresentation)
        }
        Check.equal(try Data(contentsOf: url), Data(original.utf8))
    }
}


// A small executable test runner so the checks also work with Command Line
// Tools alone. Failed checks are reported even in optimized builds.
@MainActor
private enum Check {
    static var failures = 0

    static func that(_ condition: Bool, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        guard !condition else { return }
        failures += 1
        print("FAIL \(file):\(line) \(message)")
    }

    static func isFalse(_ condition: Bool, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        that(!condition, message, file: file, line: line)
    }

    static func equal<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        that(actual == expected, message.isEmpty ? "Values differ" : message, file: file, line: line)
    }

    static func isNil<T>(_ value: T?, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        that(value == nil, message, file: file, line: line)
    }

    static func notNil<T>(_ value: T?, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        that(value != nil, message, file: file, line: line)
    }

    static func unwrap<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) throws -> T {
        guard let value else { throw MissingValue(location: "\(file):\(line)") }
        return value
    }

    private struct MissingValue: Error { let location: String }
}

@MainActor
private final class Signal {
    var isInverted = false
    private var count = 0

    func fulfill() { count += 1 }

    func wait(timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while count == 0 && Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        Check.equal(count, isInverted ? 0 : 1, "Unexpected number of image callbacks")
    }
}

@main
private struct TextChecks {
    @MainActor
    static func main() async {
        let suite = ClipboardChecks()
        let tests: [(String, () async throws -> Void)] = [
            ("testStartsOptedOutAndOnlyCapturesNewTextAfterEnabling", suite.testStartsOptedOutAndOnlyCapturesNewTextAfterEnabling),
            ("testImageOnlyModeDoesNotCaptureText", suite.testImageOnlyModeDoesNotCaptureText),
            ("testRoundTripPreservesUTF8WhitespaceAndRestoresAfterRestart", suite.testRoundTripPreservesUTF8WhitespaceAndRestoresAfterRestart),
            ("testPrivacyAndFileMarkersAreRejectedOnAnyItem", suite.testPrivacyAndFileMarkersAreRejectedOnAnyItem),
            ("testRichTextUsesPlainRepresentationAndURLTextStaysText", suite.testRichTextUsesPlainRepresentationAndURLTextStaysText),
            ("testMultipleTextItemsAreNotSilentlyJoined", suite.testMultipleTextItemsAreNotSilentlyJoined),
            ("testConsecutiveDuplicateIsSkippedButRemovedClippingCanReturn", suite.testConsecutiveDuplicateIsSkippedButRemovedClippingCanReturn),
            ("testInvalidAndOversizedTextAreRejectedWithoutTruncatingAcceptedText", suite.testInvalidAndOversizedTextAreRejectedWithoutTruncatingAcceptedText),
            ("testInvalidBackingFileCannotBeRestoredOrClearClipboard", suite.testInvalidBackingFileCannotBeRestoredOrClearClipboard),
            ("testCapacityAndRestoreKeepImagesAndTextInOrder", suite.testCapacityAndRestoreKeepImagesAndTextInOrder),
            ("testImageCaptureAndCopyStillOfferPNGAndFileURL", suite.testImageCaptureAndCopyStillOfferPNGAndFileURL),
            ("testTextOnlyModeDoesNotCaptureImagesAndStopCancelsImageDecode", suite.testTextOnlyModeDoesNotCaptureImagesAndStopCancelsImageDecode),
            ("testTextPreviewRendersWithoutChangingBackingText", suite.testTextPreviewRendersWithoutChangingBackingText),
        ]
        for (name, test) in tests {
            let before = Check.failures
            do { try await test() }
            catch { Check.that(false, "\(name): \(error)") }
            print("\(Check.failures == before ? "PASS" : "FAIL") \(name)")
        }
        print("\(tests.count) checks, \(Check.failures) failures")
        exit(Check.failures == 0 ? 0 : 1)
    }
}
