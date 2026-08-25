import Foundation

struct PortEntry: Identifiable, Hashable {
    let id = UUID()
    let proto: String   // "TCP" or "UDP"
    let port: Int
    let address: String
    let pid: Int32
    let command: String
}

/// Process names that clutter the list but aren't dev/local servers
/// (browsers, OS daemons, background sync agents). Filtered by default.
enum NoiseFilter {
    static let blockedNames: Set<String> = [
        "chrome", "google chrome helper", "safari", "safari networking",
        "firefox", "microsoft edge", "brave browser", "opera",
        "mdnsresponder", "rapportd", "controlcenter", "sharingd",
        "identityservicesd", "airplayxpchelper", "bluetoothd",
        "nsurlsessiond", "callservicesd", "trustd", "syslogd",
        "windowserver", "launchd", "cloudd", "bird", "photoanalysisd",
        "coreduetd", "assistantd", "siriknowledged", "searchpartyuseragent",
    ]

    static func isNoise(_ command: String) -> Bool {
        blockedNames.contains(command.lowercased())
    }
}
