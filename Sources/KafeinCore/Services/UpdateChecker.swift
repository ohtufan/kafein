import Foundation

public final class UpdateChecker: Sendable {
    private struct Release: Decodable {
        let tag_name: String
        let html_url: String
    }

    private static let apiURL = URL(string: "https://api.github.com/repos/ohtufan/kafein/releases/latest")!
    public static let releasesURL = URL(string: "https://github.com/ohtufan/kafein/releases")!
    public static let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2.0"

    public init() {}

    /// Checks GitHub for the latest release. Returns the version string (without "v" prefix) if newer, nil otherwise.
    public func checkForUpdate() async -> String? {
        let currentVersion = Self.currentVersion

        do {
            var request = URLRequest(url: Self.apiURL)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }

            let release = try JSONDecoder().decode(Release.self, from: data)
            let latestVersion = release.tag_name.hasPrefix("v")
                ? String(release.tag_name.dropFirst())
                : release.tag_name

            return isNewer(latestVersion, than: currentVersion) ? latestVersion : nil
        } catch {
            return nil
        }
    }

    private func isNewer(_ remote: String, than local: String) -> Bool {
        let remoteParts = remote.split(separator: ".").compactMap { Int($0) }
        let localParts = local.split(separator: ".").compactMap { Int($0) }

        for i in 0..<max(remoteParts.count, localParts.count) {
            let r = i < remoteParts.count ? remoteParts[i] : 0
            let l = i < localParts.count ? localParts[i] : 0
            if r > l { return true }
            if r < l { return false }
        }
        return false
    }
}
