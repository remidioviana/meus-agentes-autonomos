import Foundation

/// Non-network, non-LLM fictional-only mission data and review state.
struct MissionDescriptor: Identifiable {
    let id: String
    let category: String
    let name: String
    let purpose: String
    let outcomeMetric: String
    let criticalRisk: String
    let comparator: String
    let fieldLabels: [String]
}
protocol OfflineMission {
    static var descriptor: MissionDescriptor { get }
    static func prepareLocalReview(_ values: [String], reviewed: Bool) -> String
}
enum OfflineDraft {
    static func preview(_ mission: MissionDescriptor, values: [String], reviewed: Bool) -> String {
        guard reviewed else { return "BLOCKED: User must explicitly confirm a fictional-only review." }
        guard mission.fieldLabels.count == 3 && values.count == 3 else {
            return "BLOCKED: Three mission-specific evidence fields required."
        }
        let clean = values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard clean.allSatisfy({ !$0.isEmpty && $0.count <= 500 &&
            !$0.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 }) }) else {
            return "BLOCKED: Each fictional evidence note must be 1-500 printable characters."
        }
        let labels = mission.fieldLabels.enumerated().map {
            "  \($0.offset + 1). \($0.element): PROVIDED (value not displayed)"
        }
        return ([
            "LOCAL RESEARCH PREVIEW - NEVER SUBMITTED",
            mission.id + " / " + mission.name,
            "Proposed human-reviewed action: " + mission.purpose,
            "Evidence labels verified locally:"
        ] + labels + [
            "Intended outcome to validate, not measured: " + mission.outcomeMetric,
            "Critical risk to review: " + mission.criticalRisk,
            "Existing alternative to benchmark: " + mission.comparator,
            "NOT a legal, medical, financial, accessibility or safety decision.",
            "No external actions, login, storage, data transfer or agent autonomy."
        ]).joined(separator: "\n")
    }
}
