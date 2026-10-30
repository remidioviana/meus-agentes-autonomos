import Foundation

/// BU-04 RASD Assets: offline, synthetic, review-only exception proposals.
enum RasdAssets {
    enum Metric: String, Hashable {
        case temperatureC, vibrationMmS
        var unit: String { self == .temperatureC ? "C" : "mm/s" }
    }
    enum Status: String { case invalidInput, blocked, reviewRequired, noException }
    struct Rule {
        let assetId: String
        let metric: Metric
        let minimum: Double
        let maximum: Double
        let unit: String
        let suggestedReviewer: String
    }
    struct Reading {
        let assetId: String
        let metric: Metric
        let value: Double
        let unit: String
        let observedAtSeconds: Int64
        let authorizedSource: Bool
        let evidenceId: String
    }
    struct Finding {
        let assetId: String
        let metric: Metric
        let evidenceId: String
        let suggestedReviewer: String
        let observed: Double
        let minimum: Double
        let maximum: Double
    }
    struct Report {
        let status: Status
        let findings: [Finding]
        let explanation: String
        let disclosure = "Synthetic offline review only. No dispatch, safety clearance or automatic assignment."
    }
    private static func matches(_ value: String, _ pattern: String) -> Bool {
        value.range(of: pattern, options: .regularExpression) != nil
    }
    static func evaluate(rules: [Rule], readings: [Reading], nowSeconds: Int64) -> Report {
        func invalid(_ why: String) -> Report { Report(status: .invalidInput, findings: [], explanation: why) }
        func blocked(_ why: String) -> Report { Report(status: .blocked, findings: [], explanation: why) }
        if nowSeconds <= 0 || nowSeconds > Int64.max - 300 || rules.isEmpty || readings.isEmpty || rules.count > 100 || readings.count > 100 {
            return invalid("Expected a positive clock and 1..100 rules and readings")
        }
        struct Key: Hashable { let assetId: String; let metric: Metric }
        struct EvidenceKey: Hashable { let assetId: String; let metric: Metric; let evidenceId: String }
        var ruleIndex: [Key: Rule] = [:]
        for rule in rules {
            if !matches(rule.assetId, "^[A-Za-z0-9_-]{1,40}$") || rule.unit != rule.metric.unit ||
                !rule.minimum.isFinite || !rule.maximum.isFinite || rule.minimum >= rule.maximum ||
                rule.suggestedReviewer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || rule.suggestedReviewer.count > 60 {
                return invalid("Invalid rule fields")
            }
            let key = Key(assetId: rule.assetId, metric: rule.metric)
            if ruleIndex[key] != nil { return invalid("Duplicate asset/metric rule") }
            ruleIndex[key] = rule
        }
        var seen = Set<EvidenceKey>()
        var findings: [Finding] = []
        for reading in readings {
            if !matches(reading.assetId, "^[A-Za-z0-9_-]{1,40}$") ||
                !matches(reading.evidenceId, "^[A-Za-z0-9_-]{1,64}$") ||
                !reading.value.isFinite || reading.unit != reading.metric.unit {
                return invalid("Invalid reading fields")
            }
            let evidenceKey = EvidenceKey(assetId: reading.assetId, metric: reading.metric, evidenceId: reading.evidenceId)
            if !seen.insert(evidenceKey).inserted { return invalid("Duplicate evidence") }
            if !reading.authorizedSource { return blocked("Source authorization not attested") }
            if reading.observedAtSeconds <= 0 || reading.observedAtSeconds > nowSeconds + 300 ||
                reading.observedAtSeconds < nowSeconds - 86_400 {
                return blocked("Reading is stale or beyond allowed clock skew")
            }
            guard let rule = ruleIndex[Key(assetId: reading.assetId, metric: reading.metric)] else {
                return blocked("No approved review rule for asset/metric")
            }
            if reading.value < rule.minimum || reading.value > rule.maximum {
                findings.append(Finding(assetId: reading.assetId, metric: reading.metric,
                    evidenceId: reading.evidenceId, suggestedReviewer: rule.suggestedReviewer,
                    observed: reading.value, minimum: rule.minimum, maximum: rule.maximum))
            }
        }
        if findings.isEmpty { return Report(status: .noException, findings: [], explanation: "No out-of-range readings in supplied batch") }
        findings.sort {
            if $0.assetId != $1.assetId { return $0.assetId < $1.assetId }
            if $0.metric.rawValue != $1.metric.rawValue { return $0.metric.rawValue < $1.metric.rawValue }
            return $0.evidenceId < $1.evidenceId
        }
        return Report(status: .reviewRequired, findings: findings,
            explanation: "Human review required; no task has been assigned")
    }
}
