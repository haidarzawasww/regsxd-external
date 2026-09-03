import SwiftUI

// MARK: - Security Menu View

struct SecurityMenuView: View {
    @State private var results: [UUID: InjectResult] = [:]
    @State private var working: UUID? = nil
    @State private var progress: [UUID: Double] = [:]
    @State private var consoleLogs: [String] = []

    let buttons: [InjectButton] = [
        InjectButton(
            name: "BYPASS ANTICHEAT",
            category: "SECURITY",
            bundleID: "com.dts.freefireth",
            targetPath: "Documents/contentcache/Compulsory/ios/gameassetbundles/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
            resourceFileName: "cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
            resourceSubfolder: "patches/Bypass anticheats"
        ),
    ]

    private func log(_ msg: String) {
        let ts = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        DispatchQueue.main.async {
            consoleLogs.append("[\(ts)] \(msg)")
            if consoleLogs.count > 40 { consoleLogs.removeFirst() }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("SECURITY")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.red.opacity(0.8))
                                        .kerning(1.5)
                                    Rectangle()
                                        .fill(Color.red.opacity(0.2))
                                        .frame(height: 1)
                                }
                                .padding(.horizontal, 16)

                                VStack(spacing: 10) {
                                    ForEach(buttons) { button in
                                        InjectButtonCard(
                                            button: button,
                                            result: results[button.id],
                                            isWorking: working == button.id,
                                            progress: progress[button.id] ?? 0
                                        ) {
                                            inject(button)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                    }

                    // Console
                    ConsoleView(logs: consoleLogs)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Security")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func inject(_ button: InjectButton) {
        guard working != button.id else { return }

        let resourceURL: URL? = {
            let bundleBase = URL(fileURLWithPath: Bundle.main.bundlePath)
            let subfolderPath = bundleBase
                .appendingPathComponent(button.resourceSubfolder)
                .appendingPathComponent(button.resourceFileName)
            if FileManager.default.fileExists(atPath: subfolderPath.path) {
                return subfolderPath
            }
            let rootPath = bundleBase.appendingPathComponent(button.resourceFileName)
            return FileManager.default.fileExists(atPath: rootPath.path) ? rootPath : nil
        }()

        guard let resourceURL else {
            results[button.id] = .failed("File not found in bundle")
            log("\(button.name) — inject error: file not found")
            return
        }

        working = button.id
        results[button.id] = .working
        progress[button.id] = 0

        let id = button.id
        let startTime = Date()
        let duration: Double = 5.0

        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let pct = min(elapsed / duration, 1.0)
            DispatchQueue.main.async { progress[id] = pct }
            if pct >= 1.0 { timer.invalidate() }
        }

        Task.detached(priority: .userInitiated) {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            do {
                let containerURL = try resolveContainer(bundleID: button.bundleID)
                let targetURL = containerURL.appendingPathComponent(button.targetPath)
                let dir = targetURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                let data = try Data(contentsOf: resourceURL)
                let staging = dir.appendingPathComponent(".regsxd-inject-\(UUID().uuidString)")
                try data.write(to: staging, options: .atomic)
                let renameResult = rename(staging.path, targetURL.path)
                if renameResult != 0 {
                    let errMsg = String(cString: strerror(errno))
                    try? FileManager.default.removeItem(at: staging)
                    throw InjectError.renameFailed(errMsg)
                }
                await MainActor.run {
                    results[button.id] = .success
                    progress[button.id] = 1.0
                    working = nil
                    log("\(button.name) — apply success")
                }
            } catch {
                await MainActor.run {
                    results[button.id] = .failed(error.localizedDescription)
                    working = nil
                    log("\(button.name) — inject error: \(error.localizedDescription)")
                }
            }
        }
    }
}
