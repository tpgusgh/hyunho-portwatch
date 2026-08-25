import SwiftUI

struct ContentView: View {
    @State private var entries: [PortEntry] = []
    @State private var showAll = false
    @State private var pendingKill: PortEntry?
    @State private var selection: PortEntry.ID?

    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    private var visibleEntries: [PortEntry] {
        let filtered = showAll ? entries : entries.filter { !NoiseFilter.isNoise($0.command) }
        return filtered.sorted { $0.port < $1.port }
    }

    var body: some View {
        VStack(spacing: 0) {
            Table(visibleEntries, selection: $selection) {
                TableColumn("Proto", value: \.proto).width(50)
                TableColumn("Port") { entry in Text("\(entry.port)") }.width(70)
                TableColumn("Address", value: \.address)
                TableColumn("PID") { entry in Text("\(entry.pid)") }.width(60)
                TableColumn("Process", value: \.command)
                TableColumn("") { entry in
                    Button("종료") { pendingKill = entry }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.red)
                }.width(50)
            }

            Divider()

            HStack {
                Toggle("모두 보기 (브라우저/시스템 포함)", isOn: $showAll)
                Spacer()
                Text("\(visibleEntries.count)개")
                    .foregroundStyle(.secondary)
                Button("새로고침") { refresh() }
            }
            .padding(8)
        }
        .frame(minWidth: 560, minHeight: 360)
        .onAppear { refresh() }
        .onReceive(timer) { _ in refresh() }
        .alert(item: $pendingKill) { entry in
            Alert(
                title: Text("\(entry.command) (PID \(entry.pid)) 종료할까요?"),
                message: Text("포트 \(entry.port)번을 점유 중입니다."),
                primaryButton: .destructive(Text("종료")) {
                    kill(entry.pid, SIGTERM)
                    refresh()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }

    private func refresh() {
        entries = PortScanner.scanAll()
    }
}
