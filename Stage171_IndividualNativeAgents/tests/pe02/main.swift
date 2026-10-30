import Foundation

func review(_ channel: String = "APPLE", _ date: String = "2026-10-20", _ evidence: String = "NONE", _ consent: Bool = true) -> String {
    IthbatCancellationMission.prepareLocalReview([channel, date, evidence], reviewed: consent)
}
func check(_ condition: Bool, _ name: String) {
    if !condition { fatalError("FAIL: \(name)") }
}
check(review().contains("REQUEST_RECORDED"), "requested")
check(review("GOOGLE_PLAY").contains("Google Play"), "google")
check(review("DIRECT_MERCHANT").contains("no merchant-specific route"), "merchant")
check(review("APPLE", "2026-10-20", "RECEIPT:ABC-123").contains("RECEIPT_REPORTED"), "receipt")
let checked = review("APPLE", "2026-10-20", "RECEIPT:ABC-123|CHECKED:2026-10-25")
check(checked.contains("FOLLOW_UP_REPORTED"), "checked")
check(!checked.contains("ABC-123"), "redaction")
check(checked.contains("NOT provider-verified"), "unverified")
check(checked.contains("does NOT prove cancellation"), "disclaimer")
check(review("APPLE", "2026-10-20", "NONE", false).hasPrefix("BLOCKED"), "consent")
check(review("UNKNOWN").hasPrefix("BLOCKED"), "channel")
check(review("APPLE\nSECRET").hasPrefix("BLOCKED"), "newline")
check(review("APPLE", "2026-02-30").hasPrefix("BLOCKED"), "invalid date")
check(review("APPLE", "2024-02-29").contains("REQUEST_RECORDED"), "leap")
check(review("APPLE", "2025-02-29").hasPrefix("BLOCKED"), "non leap")
check(review("APPLE", "1999-12-31").hasPrefix("BLOCKED"), "year bound")
check(review("APPLE", "2026-2-1").hasPrefix("BLOCKED"), "date syntax")
check(review("APPLE", "2026-10-20", "RECEIPT:AB").hasPrefix("BLOCKED"), "short receipt")
check(review("APPLE", "2026-10-20", "RECEIPT:ABC@123").hasPrefix("BLOCKED"), "unsafe receipt")
check(review("APPLE", "2026-10-20", "RECEIPT:ABC-123|CHECKED:2026-10-19").hasPrefix("BLOCKED"), "chronology")
check(review("APPLE", "2026-10-20", "RECEIPT:ABC-123|CHECKED:2026-02-30").hasPrefix("BLOCKED"), "check date")
check(review("APPLE", "2026-10-20", "CHECKED:2026-10-25").hasPrefix("BLOCKED"), "orphan checked")
check(review("APPLE", "2026-10-20", "RECEIPT:ABC-123\nSECRET").hasPrefix("BLOCKED"), "control")
check(IthbatCancellationMission.prepareLocalReview(["APPLE", "2026-10-20"], reviewed: true).hasPrefix("BLOCKED"), "arity")
print("PASS Swift PE-02: 23 assertions")
