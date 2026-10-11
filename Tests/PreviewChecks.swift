import Foundation

@main
struct PreviewChecks {
    static func main() {
        let preview = CommandLine.arguments.contains("--preview")
        precondition(AppIdentity.isPreview == preview)
        let expectedName = preview ? "Textline Preview" : "Tendedero"
        let expectedDirectory = preview ? "TextlinePreview" : "Tendedero"
        precondition(AppIdentity.name == expectedName)
        precondition(Inbox.folder.lastPathComponent == "Screenshots")
        precondition(Inbox.folder.deletingLastPathComponent().lastPathComponent == expectedDirectory)
        precondition(L("Quit Tendedero").contains(expectedName))
        if preview {
            precondition(Bundle.main.bundleIdentifier == "io.github.lnte39.TextlinePreviewValidation")
        }
        print("PASS \(preview ? "preview" : "ordinary") identity, localization and storage isolation")
    }
}
