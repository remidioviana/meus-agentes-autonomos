import Foundation

typealias R = RasdAssets
let now: Int64 = 1_800_000_000
let temp = R.Rule(assetId: "A1", metric: .temperatureC, minimum: 10, maximum: 30, unit: "C", suggestedReviewer: "Reviewer A")
let vib = R.Rule(assetId: "B2", metric: .vibrationMmS, minimum: 0, maximum: 5, unit: "mm/s", suggestedReviewer: "Reviewer B")
func t(_ value: Double = 20, at: Int64 = now, authorized: Bool = true, evidence: String = "E1", unit: String = "C", asset: String = "A1") -> R.Reading {
    R.Reading(assetId: asset, metric: .temperatureC, value: value, unit: unit,
              observedAtSeconds: at, authorizedSource: authorized, evidenceId: evidence)
}
func v(_ value: Double = 4, evidence: String = "E2") -> R.Reading {
    R.Reading(assetId: "B2", metric: .vibrationMmS, value: value, unit: "mm/s",
              observedAtSeconds: now, authorizedSource: true, evidenceId: evidence)
}
var checks = 0
func expect(_ name: String, _ expected: R.Status, rules: [R.Rule] = [temp], readings: [R.Reading] = [t()], findings: Int? = nil) {
    let actual = R.evaluate(rules: rules, readings: readings, nowSeconds: now)
    precondition(actual.status == expected, "\(name) expected \(expected) got \(actual.status): \(actual.explanation)")
    if let findings = findings { precondition(actual.findings.count == findings, "\(name) findings mismatch") }
    precondition(actual.disclosure.contains("No dispatch"))
    checks += 1
    print("PASS \(name)")
}
expect("high_temp", .reviewRequired, readings: [t(31)], findings: 1)
expect("normal_temp", .noException, findings: 0)
expect("min_inclusive", .noException, readings: [t(10)])
expect("max_inclusive", .noException, readings: [t(30)])
expect("low_temp", .reviewRequired, readings: [t(9)], findings: 1)
expect("high_vibration", .reviewRequired, rules: [vib], readings: [v(5.1)], findings: 1)
expect("normal_vibration", .noException, rules: [vib], readings: [v(5)])
expect("two_findings", .reviewRequired, rules: [temp,vib], readings: [v(7),t(35)], findings: 2)
expect("unauthorized", .blocked, readings: [t(35, authorized: false)], findings: 0)
expect("stale", .blocked, readings: [t(at: now-86_401)])
expect("stale_boundary", .noException, readings: [t(at: now-86_400)])
expect("future", .blocked, readings: [t(at: now+301)])
expect("future_boundary", .noException, readings: [t(at: now+300)])
expect("missing_rule", .blocked, readings: [t(asset: "Other")])
expect("duplicate_rule", .invalidInput, rules: [temp,temp])
expect("duplicate_evidence", .invalidInput, readings: [t(),t()])
expect("nan", .invalidInput, readings: [t(Double.nan)])
expect("infinite", .invalidInput, readings: [t(Double.infinity)])
expect("wrong_unit", .invalidInput, readings: [t(unit: "F")])
expect("bad_threshold", .invalidInput, rules: [.init(assetId: "A1", metric: .temperatureC, minimum: 30, maximum: 30, unit: "C", suggestedReviewer: "Reviewer A")])
expect("blank_reviewer", .invalidInput, rules: [.init(assetId: "A1", metric: .temperatureC, minimum: 10, maximum: 30, unit: "C", suggestedReviewer: " ")])
expect("missing_evidence", .invalidInput, readings: [t(evidence: "")])
expect("bad_asset", .invalidInput, readings: [t(asset: "bad asset")])
expect("no_readings", .invalidInput, readings: [])
expect("no_rules", .invalidInput, rules: [])
expect("too_many", .invalidInput, readings: (1...101).map { t(evidence: "E\($0)") })
precondition(R.evaluate(rules: [temp], readings: [t()], nowSeconds: Int64.max).status == .invalidInput)
checks += 1
print("PASS clock_overflow")
let review = R.evaluate(rules: [temp,vib], readings: [v(6),t(40)], nowSeconds: now)
precondition(review.findings.map { $0.assetId } == ["A1", "B2"])
precondition(review.findings[0].suggestedReviewer == "Reviewer A")
checks += 1
print("PASS stable_sort_and_owner")
print("SWIFT PASS \(checks)/\(checks)")
