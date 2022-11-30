import Foundation

enum AppConstants {
    static let apikey = "act_safe_ca22"
    static let newsURL = "https://www.actsafe.ca/updates/"
    static let eventsURL = "https://www.actsafe.ca/events/"
    static let termsOfService = "https://actsafereactdev.appskeeper.in/terms-conditions"
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "XX"
}
