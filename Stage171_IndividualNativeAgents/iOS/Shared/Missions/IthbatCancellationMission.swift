import Foundation

/// PE-02: local fictional cancellation-evidence timeline, not an account cancellation tool.
enum IthbatCancellationMission: OfflineMission {
    static let descriptor = MissionDescriptor(
        id: "PE-02",
        category: "Personal",
        name: "ITHBAT Cancellation",
        purpose: "Guide provider-specific exit steps and preserve user-confirmed cancellation receipt",
        outcomeMetric: "Unwanted renewals after attempted cancellation",
        criticalRisk: "Unauthorized account actions",
        comparator: "Apple Google and direct merchant subscriptions",
        fieldLabels: [
            "Fictional billing channel: APPLE, GOOGLE_PLAY or DIRECT_MERCHANT",
            "Fictional cancellation request date (YYYY-MM-DD)",
            "Fictional evidence: NONE, RECEIPT:ABC-123 or RECEIPT:ABC-123|CHECKED:YYYY-MM-DD"
        ]
    )

    private static let receiptPattern = #"^RECEIPT:([A-Za-z0-9][A-Za-z0-9._-]{2,39})(?:\|CHECKED:([0-9]{4}-[0-9]{2}-[0-9]{2}))?$"#
    private static func parseDate(_ raw: String) -> Date? {
        guard raw.range(of: #"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"#, options: .regularExpression) != nil,
              let year = Int(raw.prefix(4)), (2000...2100).contains(year) else { return nil }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        guard let parsed = formatter.date(from: raw), formatter.string(from: parsed) == raw else { return nil }
        return parsed
    }

    static func prepareLocalReview(_ values: [String], reviewed: Bool) -> String {
        guard reviewed else { return "BLOCKED: Explicit fictional-only user review required." }
        guard values.count == 3 && values.allSatisfy({ $0.utf16.count <= 120 &&
            !$0.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 }) }) else {
            return "BLOCKED: Exactly three short printable fictional fields required."
        }
        let channel = values[0].trimmingCharacters(in: .whitespaces)
        let guidance: String
        switch channel {
        case "APPLE":
            guidance = "Check the official Apple subscription-management instructions; do not assume deleting an app cancels billing."
        case "GOOGLE_PLAY":
            guidance = "Check the official Google Play subscription-management instructions; uninstalling an app is not cancellation."
        case "DIRECT_MERCHANT":
            guidance = "Locate the merchant's own official cancellation and receipt instructions; no merchant-specific route is verified here."
        default:
            return "BLOCKED: Choose APPLE, GOOGLE_PLAY or DIRECT_MERCHANT; do not enter account credentials."
        }
        let dateText = values[1].trimmingCharacters(in: .whitespaces)
        guard let requested = parseDate(dateText) else {
            return "BLOCKED: Enter a valid Gregorian request date (YYYY-MM-DD, 2000-2100)."
        }
        let evidence = values[2].trimmingCharacters(in: .whitespaces)
        let regex = try! NSRegularExpression(pattern: receiptPattern)
        let range = NSRange(evidence.startIndex..<evidence.endIndex, in: evidence)
        let receipt = regex.firstMatch(in: evidence, range: range)
        guard evidence == "NONE" || receipt != nil else {
            return "BLOCKED: Use NONE or RECEIPT:reference, optionally followed by |CHECKED:YYYY-MM-DD."
        }
        var checked: Date? = nil
        if let receipt = receipt, receipt.range(at: 2).location != NSNotFound {
            guard let textRange = Range(receipt.range(at: 2), in: evidence),
                  let parsed = parseDate(String(evidence[textRange])) else {
                return "BLOCKED: Invalid Gregorian statement-check date."
            }
            checked = parsed
        }
        if let checked = checked, checked < requested {
            return "BLOCKED: A follow-up check cannot predate the fictional request."
        }
        let state = checked != nil ? "FOLLOW_UP_REPORTED" : (receipt != nil ? "RECEIPT_REPORTED" : "REQUEST_RECORDED")
        return [
            "LOCAL FICTIONAL EVIDENCE TIMELINE - NEVER SUBMITTED",
            "PE-02 / ITHBAT Cancellation",
            "Billing channel: \(channel)",
            "Request date: \(dateText) (user-entered, not independently verified)",
            "Evidence stage: \(state) (user-reported, NOT provider-verified)",
            "Receipt identifier withheld; its syntax does not establish authenticity.",
            "Next human review: \(guidance)",
            "Confirm the actual provider status and subsequent statement directly with the provider; a receipt alone does NOT prove cancellation or prevent renewal.",
            "No credentials, account access, provider contact, billing action, storage or transmission. No cancellation success claim."
        ].joined(separator: "\n")
    }
}
