import Foundation

/// The separately packaged local preview keeps its settings and files apart.
/// Ordinary builds retain the upstream identity and screenshot behavior.
enum AppIdentity {
    static var isPreview: Bool {
        Bundle.main.object(forInfoDictionaryKey: "TextlinePreview") as? Bool == true
    }
    static var name: String { isPreview ? "Textline Preview" : "Tendedero" }
    static var supportDirectory: String { isPreview ? "TextlinePreview" : "Tendedero" }
}
