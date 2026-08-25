import Foundation

enum PortScanner {
    static func scanAll() -> [PortEntry] {
        scan(proto: "TCP", args: ["-iTCP", "-sTCP:LISTEN", "-P", "-n", "-F", "pcn"]) +
        scan(proto: "UDP", args: ["-iUDP", "-P", "-n", "-F", "pcn"])
    }

    /// Runs lsof with `-F pcn` (machine-readable: pid, command, name lines) and parses it.
    private static func scan(proto: String, args: [String]) -> [PortEntry] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            return []
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        var entries: [PortEntry] = []
        var currentPID: Int32 = 0
        var currentCommand = ""

        for line in output.split(separator: "\n") {
            guard let tag = line.first else { continue }
            let value = String(line.dropFirst())
            switch tag {
            case "p":
                currentPID = Int32(value) ?? 0
            case "c":
                currentCommand = value
            case "n":
                if let (address, port) = parsePort(value) {
                    entries.append(PortEntry(proto: proto, port: port, address: address, pid: currentPID, command: currentCommand))
                }
            default:
                break
            }
        }
        return entries
    }

    /// lsof NAME field looks like "*:3000" or "127.0.0.1:5353" or "[::1]:8080".
    private static func parsePort(_ name: String) -> (address: String, port: Int)? {
        guard let colonIndex = name.lastIndex(of: ":") else { return nil }
        let portPart = name[name.index(after: colonIndex)...]
            .trimmingCharacters(in: .whitespaces)
        guard let port = Int(portPart) else { return nil }
        let address = String(name[..<colonIndex])
        return (address, port)
    }
}
