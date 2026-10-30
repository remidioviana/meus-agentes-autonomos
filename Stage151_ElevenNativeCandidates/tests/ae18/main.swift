import Foundation
private var checks = 0
func verify(_ value: Bool) { precondition(value); checks += 1 }
func rejects(_ text: String, _ consent: Bool = true) {
    do { _ = try LafzRightsExplainer.analyze(text, confirmedFictional: consent); fatalError("accepted invalid input") }
    catch LafzRightsExplainer.Failure.fictionalConfirmationRequired { checks += 1 }
    catch LafzRightsExplainer.Failure.invalidLength { checks += 1 }
    catch LafzRightsExplainer.Failure.controlCharacter { checks += 1 }
    catch { fatalError("unexpected error: \(error)") }
}
@main struct Run {
static func main() throws {
    typealias E = LafzRightsExplainer
    let report = try E.analyze("You MUST respond within ten days, unless exempt; you may ask.", confirmedFictional: true)
    verify(report.findings.map { $0.cue.rawValue } == ["OBLIGATION", "PERMISSION", "TIME_REFERENCE", "EXCEPTION"])
    verify(try E.analyze("shall", confirmedFictional: true).findings.first?.cue == .obligation)
    verify(try E.analyze("CAN", confirmedFictional: true).findings.first?.cue == .permission)
    verify(try E.analyze("after", confirmedFictional: true).findings.first?.cue == .timeReference)
    verify(try E.analyze("except", confirmedFictional: true).findings.first?.cue == .exception)
    verify(try E.analyze("maybe", confirmedFictional: true).findings.isEmpty)
    verify(try E.analyze("shell", confirmedFictional: true).findings.isEmpty)
    verify(try E.analyze("sample notice", confirmedFictional: true).findings.isEmpty)
    verify(try E.analyze("must MUST", confirmedFictional: true).findings.count == 1)
    verify(try E.analyze("must", confirmedFictional: true).findings.first!.reviewQuestion.contains("reviewer"))
    verify(report.disclosure.contains("not legal advice"))
    verify(!String(describing: report).contains("ten days"))
    verify(try E.analyze("يجب", confirmedFictional: true).findings.isEmpty)
    verify(try E.analyze("must", confirmedFictional: true).findings.first!.explanation.contains("unverified"))
    rejects("must", false)
    rejects("")
    rejects("   ")
    rejects(String(repeating: "a", count: 1501))
    rejects("must\nnow")
    verify(try E.analyze(String(repeating: "a", count: 1500), confirmedFictional: true).findings.isEmpty)
    print("AE-18 Swift: \(checks)/\(checks) assertions PASS")
}
}
