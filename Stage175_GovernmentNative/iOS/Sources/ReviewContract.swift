import Foundation

/// Synthetic research only. No connections, credentials, actual government records or real-world decisions.
struct GovernmentCase {
    let evidence: [String]
    let indicators: [String: String]
    let values: [Double]
    let note: String
    let syntheticConfirmed: Bool
}
struct GovernmentFinding {
    let missionId: String
    let missionName: String
    let status: String
    let concerns: [String]
    let externalActionExecuted: Bool
    let humanReviewRequired: Bool
}
protocol GovernmentMission {
    static var id: String { get }
    static var name: String { get }
    static func evaluate(_ input: GovernmentCase) -> GovernmentFinding
}
enum SyntheticGuard {
    static func refusal(_ id: String, _ name: String, _ input: GovernmentCase) -> GovernmentFinding? {
        if !input.syntheticConfirmed {
            return GovernmentFinding(missionId: id, missionName: name, status: "BLOCKED",
                    concerns: ["Fictional-only confirmation required."],
                    externalActionExecuted: false, humanReviewRequired: true)
        }
        if input.values.count != 3 || input.values.contains(where: { !$0.isFinite }) ||
           input.note.count > 500 || input.evidence.count > 30 ||
           input.evidence.contains(where: { $0.isEmpty || $0.count > 100 }) ||
           input.indicators.count > 30 ||
           input.indicators.contains(where: { $0.key.count > 80 || $0.value.count > 100 }) {
            return GovernmentFinding(missionId: id, missionName: name, status: "INVALID_SYNTHETIC_CASE",
                  concerns: ["Input shape or bounds invalid."], externalActionExecuted: false,
                  humanReviewRequired: true)
        }
        return nil
    }
    static func finding(_ id: String, _ name: String, _ concerns: [String]) -> GovernmentFinding {
        GovernmentFinding(missionId: id, missionName: name,
            status: concerns.isEmpty ? "NO_ISSUE_IN_SYNTHETIC_SAMPLE" : "REVIEW_REQUIRED",
            concerns: concerns.isEmpty ? ["Limited synthetic checks found no exception; NOT government validation."] : concerns,
            externalActionExecuted: false, humanReviewRequired: true)
    }
}
