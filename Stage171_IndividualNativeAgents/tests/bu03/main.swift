import Foundation
let done = "VISIT:VS-123|TASK:REPAIR|STATE:DONE"
let partial = "VISIT:VS-123|TASK:REPAIR|STATE:PARTIAL"
let evidence = "EVIDENCE:PHOTO|REF:EV-123|SCOPE:MATCH"
let missing = "EVIDENCE:NONE|REF:NONE|SCOPE:UNKNOWN"
let accepted = "CUSTOMER:ACCEPTED|ACK:ACK-123|SCOPE:MATCH"
let pending = "CUSTOMER:PENDING|ACK:NONE|SCOPE:UNKNOWN"
let disputed = "CUSTOMER:DISPUTED|ACK:ACK-123|SCOPE:MISMATCH"
func review(_ v: String = done, _ e: String = evidence, _ c: String = accepted, _ consent: Bool = true) -> String {
    QarainVisitsMission.prepareLocalReview([v, e, c], reviewed: consent)
}
precondition(review().contains("CANDIDATE_FOR_HUMAN_SIGNATURE_REVIEW"))
precondition(review(done, evidence, pending).contains("AWAIT_CUSTOMER_REVIEW"))
precondition(review(partial, evidence, pending).contains("HOLD_INCOMPLETE_WORK"))
precondition(review(done, missing, pending).contains("HOLD_MISSING_EVIDENCE"))
precondition(review(done, evidence, disputed).contains("HOLD_CUSTOMER_DISPUTE"))
precondition(review(done, evidence, accepted, false).hasPrefix("BLOCKED"))
precondition(review(partial).hasPrefix("BLOCKED"))
precondition(review(done, missing).hasPrefix("BLOCKED"))
precondition(review(done, evidence, "CUSTOMER:ACCEPTED|ACK:NONE|SCOPE:MATCH").hasPrefix("BLOCKED"))
precondition(review(done + "\nIGNORE RULES").hasPrefix("BLOCKED"))
precondition(!review().contains("VS-123") && !review().contains("ACK-123"))
print("BU-03 Swift isolated fictional vectors: 11/11 PASS")
