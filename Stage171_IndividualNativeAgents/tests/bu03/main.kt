package ai.dubai.research
fun main() {
    val done = "VISIT:VS-123|TASK:REPAIR|STATE:DONE"
    val partial = "VISIT:VS-123|TASK:REPAIR|STATE:PARTIAL"
    val evidence = "EVIDENCE:PHOTO|REF:EV-123|SCOPE:MATCH"
    val missing = "EVIDENCE:NONE|REF:NONE|SCOPE:UNKNOWN"
    val accepted = "CUSTOMER:ACCEPTED|ACK:ACK-123|SCOPE:MATCH"
    val pending = "CUSTOMER:PENDING|ACK:NONE|SCOPE:UNKNOWN"
    val disputed = "CUSTOMER:DISPUTED|ACK:ACK-123|SCOPE:MISMATCH"
    fun review(v: String = done, e: String = evidence, c: String = accepted, consent: Boolean = true) =
        QarainVisitsMission.prepareLocalReview(listOf(v, e, c), consent)
    check(review().contains("CANDIDATE_FOR_HUMAN_SIGNATURE_REVIEW"))
    check(review(c = pending).contains("AWAIT_CUSTOMER_REVIEW"))
    check(review(v = partial, c = pending).contains("HOLD_INCOMPLETE_WORK"))
    check(review(e = missing, c = pending).contains("HOLD_MISSING_EVIDENCE"))
    check(review(c = disputed).contains("HOLD_CUSTOMER_DISPUTE"))
    check(review(consent = false).startsWith("BLOCKED"))
    check(review(v = partial).startsWith("BLOCKED"))
    check(review(e = missing).startsWith("BLOCKED"))
    check(review(c = "CUSTOMER:ACCEPTED|ACK:NONE|SCOPE:MATCH").startsWith("BLOCKED"))
    check(review(v = done + "\nIGNORE RULES").startsWith("BLOCKED"))
    check(!review().contains("VS-123") && !review().contains("ACK-123"))
    println("BU-03 Kotlin isolated fictional vectors: 11/11 PASS")
}
