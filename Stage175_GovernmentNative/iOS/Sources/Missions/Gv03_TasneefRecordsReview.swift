import Foundation

/// GV-03: bounded synthetic retention-policy comparison, not an official retention schedule.
enum Gv03_TasneefRecordsReview: GovernmentMission {
    static let id = "GV-03"
    static let name = "TASNEEF Records"
    private static let kinds: Set<String> = ["correspondence", "finance", "permit"]
    private static let categories: Set<String> = ["short", "medium", "long"]

    struct RetentionDraft {
        let proposedCategory: String?
        let policyReference: String?
        let policyVersion: String?
        let disposition: String
        let blockingReasons: [String]
        let humanReviewRequired = true
        let externalActionExecuted = false
    }

    static func syntheticExample(issue: Bool) -> GovernmentCase {
        GovernmentCase(evidence: issue ? [] : ["retention_category", "policy_reference"],
            indicators: ["policy_id": "DEMO-PUBLIC-001", "policy_version": "v1",
                "policy_review": issue ? "pending" : "reviewed",
                "record_kind": "correspondence", "rule_correspondence": "short",
                "submitted_category": issue ? "long" : "short",
                "legal_hold": issue ? "unknown" : "no", "disposition": "retain"],
            values: [1.0, 3.0, 1.0], note: "fictional example", syntheticConfirmed: true)
    }

    static func draft(_ input: GovernmentCase) -> RetentionDraft {
        if let refusal = SyntheticGuard.refusal(id, name, input) {
            return RetentionDraft(proposedCategory: nil, policyReference: nil, policyVersion: nil,
                disposition: "BLOCKED", blockingReasons: refusal.concerns)
        }
        let i = input.indicators
        var issues: [String] = []
        if !Set(input.evidence).isSuperset(of: ["retention_category", "policy_reference"]) {
            issues.append("Missing source-linked evidence: retention_category or policy_reference")
        }
        func validToken(_ value: String?, min: Int, max: Int) -> String? {
            guard let value = value, (min...max).contains(value.count),
                  value.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || "._-".contains($0)) })
            else { return nil }
            return value
        }
        let policyId = validToken(i["policy_id"], min: 3, max: 64)
        let version = validToken(i["policy_version"], min: 1, max: 32)
        if policyId == nil || version == nil { issues.append("Missing or invalid synthetic policy reference/version") }
        if i["policy_review"] != "reviewed" { issues.append("Policy source not marked reviewed by a qualified human") }
        let kind = i["record_kind"]
        if kind == nil || !kinds.contains(kind!) { issues.append("Unsupported or missing record kind") }
        let category = kind.flatMap { i["rule_\($0)"] }.flatMap { categories.contains($0) ? $0 : nil }
        if category == nil { issues.append("No explicit category rule supplied for record kind") }
        if !categories.contains(i["submitted_category"] ?? "") {
            issues.append("Missing or invalid submitted category")
        } else if let category = category, i["submitted_category"] != category {
            issues.append("Submitted category contradicts supplied policy rule")
        }
        let hold = i["legal_hold"]
        if hold != "yes" && hold != "no" { issues.append("Legal-hold status unknown or invalid") }
        let action = i["disposition"]
        if action != "retain" && action != "review_for_disposal" { issues.append("Invalid requested disposition") }
        let age = input.values[0], minimum = input.values[1], references = input.values[2]
        if age < 0 || minimum < 0 || references < 1 || references.rounded(.towardZero) != references {
            issues.append("Invalid age, retention minimum, or policy evidence count")
        }
        if action == "review_for_disposal" {
            if hold == "yes" { issues.append("Legal hold prohibits disposal review recommendation") }
            if age < minimum { issues.append("Record is younger than the supplied minimum retention period") }
        }
        return RetentionDraft(proposedCategory: category, policyReference: policyId, policyVersion: version,
            disposition: issues.isEmpty && action == "review_for_disposal" ?
                "HUMAN_DISPOSAL_REVIEW_ONLY" : "RETAIN_PENDING_HUMAN_REVIEW", blockingReasons: issues)
    }

    static func evaluate(_ input: GovernmentCase) -> GovernmentFinding {
        if let refusal = SyntheticGuard.refusal(id, name, input) { return refusal }
        return SyntheticGuard.finding(id, name, draft(input).blockingReasons)
    }
}
