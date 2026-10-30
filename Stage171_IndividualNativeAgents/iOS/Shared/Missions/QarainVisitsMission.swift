import Foundation

/// BU-03: synthetic visit-evidence reconciliation, never proof of work or a customer signature.
enum QarainVisitsMission: OfflineMission {
    static let descriptor = MissionDescriptor(
        id: "BU-03", category: "Business", name: "QARAIN Visits",
        purpose: "Assemble signed customer-reviewed work-completion packet",
        outcomeMetric: "Visit rework due to missing evidence",
        criticalRisk: "Fabricated work performed",
        comparator: "Field service management apps",
        fieldLabels: [
            "Fictional visit (VISIT:VS-123|TASK:REPAIR|STATE:DONE)",
            "Claimed evidence (EVIDENCE:PHOTO|REF:EV-123|SCOPE:MATCH)",
            "Claimed customer response (CUSTOMER:ACCEPTED|ACK:ACK-123|SCOPE:MATCH)"
        ]
    )
    private static let visit = try! NSRegularExpression(pattern: #"^VISIT:(VS-[A-Z0-9]{3,10})\|TASK:(REPAIR|INSPECT|INSTALL)\|STATE:(DONE|PARTIAL|NOT_DONE)$"#)
    private static let evidence = try! NSRegularExpression(pattern: #"^EVIDENCE:(PHOTO|CHECKLIST|NONE)\|REF:(EV-[A-Z0-9]{3,10}|NONE)\|SCOPE:(MATCH|UNKNOWN)$"#)
    private static let customer = try! NSRegularExpression(pattern: #"^CUSTOMER:(ACCEPTED|PENDING|DISPUTED)\|ACK:(ACK-[A-Z0-9]{3,10}|NONE)\|SCOPE:(MATCH|MISMATCH|UNKNOWN)$"#)

    private static func parts(_ pattern: NSRegularExpression, _ input: String) -> [String]? {
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        guard let match = pattern.firstMatch(in: input, range: range), match.range == range else { return nil }
        return (0..<match.numberOfRanges).compactMap { i in
            Range(match.range(at: i), in: input).map { String(input[$0]) }
        }
    }

    static func prepareLocalReview(_ values: [String], reviewed: Bool) -> String {
        guard reviewed else { return "BLOCKED: Explicit fictional-only visit review required." }
        guard values.count == 3 && values.allSatisfy({ !$0.isEmpty && $0.utf8.count <= 120 &&
            $0.utf8.allSatisfy({ $0 >= 33 && $0 <= 126 }) }) else {
            return "BLOCKED: Three short ASCII fictional fields required; no names or free-text notes."
        }
        guard let v = parts(visit, values[0]) else {
            return "BLOCKED: Invalid fictional visit ID, task or work state."
        }
        guard let e = parts(evidence, values[1]) else {
            return "BLOCKED: Invalid fictional evidence type, reference or scope."
        }
        guard let c = parts(customer, values[2]) else {
            return "BLOCKED: Invalid fictional customer response, acknowledgement or scope."
        }
        let task = v[2], state = v[3]
        let evidenceType = e[1], evidenceRef = e[2], evidenceScope = e[3]
        let customerState = c[1], ack = c[2], customerScope = c[3]
        guard (evidenceType == "NONE") == (evidenceRef == "NONE") else {
            return "BLOCKED: Evidence type and reference contradict one another."
        }
        guard !(evidenceType == "NONE" && evidenceScope == "MATCH") else {
            return "BLOCKED: Missing evidence cannot claim matching scope."
        }
        guard !(customerState == "PENDING" && (ack != "NONE" || customerScope != "UNKNOWN")) else {
            return "BLOCKED: Pending customer response cannot assert acknowledgement or scope."
        }
        guard !(customerState == "DISPUTED" && (ack == "NONE" || customerScope != "MISMATCH")) else {
            return "BLOCKED: Dispute requires a claimed reference and mismatched scope."
        }
        guard !(customerState == "ACCEPTED" && (ack == "NONE" || customerScope != "MATCH" ||
            state != "DONE" || evidenceType == "NONE" || evidenceScope != "MATCH")) else {
            return "BLOCKED: Customer acceptance conflicts with completion or claimed evidence."
        }
        let decision: String
        if customerState == "DISPUTED" { decision = "HOLD_CUSTOMER_DISPUTE" }
        else if state != "DONE" { decision = "HOLD_INCOMPLETE_WORK" }
        else if evidenceType == "NONE" { decision = "HOLD_MISSING_EVIDENCE" }
        else if evidenceScope != "MATCH" { decision = "HOLD_UNVERIFIED_SCOPE" }
        else if customerState == "PENDING" { decision = "AWAIT_CUSTOMER_REVIEW" }
        else { decision = "CANDIDATE_FOR_HUMAN_SIGNATURE_REVIEW" }
        return [
            "LOCAL FICTIONAL VISIT PACKET - NEVER SUBMITTED",
            "BU-03 / QARAIN Visits",
            "Visit, evidence and acknowledgement references withheld; no customer identity collected.",
            "Task category: \(task); claimed work state: \(state) (not verified).",
            "Claimed evidence: \(evidenceType); scope: \(evidenceScope) (not inspected).",
            "Claimed customer response: \(customerState); scope: \(customerScope) (not authenticated).",
            "Human review decision: \(decision).",
            "No actual customer signature, consent, completed work or evidence authenticity established.",
            "No live service system, media capture, storage, transmission, customer contact or closure."
        ].joined(separator: "\n")
    }
}
