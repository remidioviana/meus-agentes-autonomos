package ai.dubai.research

/** BU-03: synthetic visit-evidence reconciliation, never proof of work or a customer signature. */
internal object QarainVisitsMission : OfflineMission {
    override val descriptor = MissionDescriptor(
        id = "BU-03", category = "Business", name = "QARAIN Visits",
        purpose = "Assemble signed customer-reviewed work-completion packet",
        outcomeMetric = "Visit rework due to missing evidence",
        criticalRisk = "Fabricated work performed",
        comparator = "Field service management apps",
        fieldLabels = listOf(
            "Fictional visit (VISIT:VS-123|TASK:REPAIR|STATE:DONE)",
            "Claimed evidence (EVIDENCE:PHOTO|REF:EV-123|SCOPE:MATCH)",
            "Claimed customer response (CUSTOMER:ACCEPTED|ACK:ACK-123|SCOPE:MATCH)"
        )
    )
    private val visit = Regex("VISIT:(VS-[A-Z0-9]{3,10})\\|TASK:(REPAIR|INSPECT|INSTALL)\\|STATE:(DONE|PARTIAL|NOT_DONE)")
    private val evidence = Regex("EVIDENCE:(PHOTO|CHECKLIST|NONE)\\|REF:(EV-[A-Z0-9]{3,10}|NONE)\\|SCOPE:(MATCH|UNKNOWN)")
    private val customer = Regex("CUSTOMER:(ACCEPTED|PENDING|DISPUTED)\\|ACK:(ACK-[A-Z0-9]{3,10}|NONE)\\|SCOPE:(MATCH|MISMATCH|UNKNOWN)")

    override fun prepareLocalReview(inputs: List<String>, reviewed: Boolean): String {
        if (!reviewed) return "BLOCKED: Explicit fictional-only visit review required."
        if (inputs.size != 3 || inputs.any { it.isEmpty() || it.length > 120 ||
                    it.any { c -> c.code < 33 || c.code > 126 } })
            return "BLOCKED: Three short ASCII fictional fields required; no names or free-text notes."
        val v = visit.matchEntire(inputs[0])
            ?: return "BLOCKED: Invalid fictional visit ID, task or work state."
        val e = evidence.matchEntire(inputs[1])
            ?: return "BLOCKED: Invalid fictional evidence type, reference or scope."
        val c = customer.matchEntire(inputs[2])
            ?: return "BLOCKED: Invalid fictional customer response, acknowledgement or scope."
        val task = v.groupValues[2]
        val state = v.groupValues[3]
        val evidenceType = e.groupValues[1]
        val evidenceRef = e.groupValues[2]
        val evidenceScope = e.groupValues[3]
        val customerState = c.groupValues[1]
        val ack = c.groupValues[2]
        val customerScope = c.groupValues[3]
        if ((evidenceType == "NONE") != (evidenceRef == "NONE"))
            return "BLOCKED: Evidence type and reference contradict one another."
        if (evidenceType == "NONE" && evidenceScope == "MATCH")
            return "BLOCKED: Missing evidence cannot claim matching scope."
        if (customerState == "PENDING" && (ack != "NONE" || customerScope != "UNKNOWN"))
            return "BLOCKED: Pending customer response cannot assert acknowledgement or scope."
        if (customerState == "DISPUTED" && (ack == "NONE" || customerScope != "MISMATCH"))
            return "BLOCKED: Dispute requires a claimed reference and mismatched scope."
        if (customerState == "ACCEPTED" && (ack == "NONE" || customerScope != "MATCH" ||
                    state != "DONE" || evidenceType == "NONE" || evidenceScope != "MATCH"))
            return "BLOCKED: Customer acceptance conflicts with completion or claimed evidence."
        val decision = when {
            customerState == "DISPUTED" -> "HOLD_CUSTOMER_DISPUTE"
            state != "DONE" -> "HOLD_INCOMPLETE_WORK"
            evidenceType == "NONE" -> "HOLD_MISSING_EVIDENCE"
            evidenceScope != "MATCH" -> "HOLD_UNVERIFIED_SCOPE"
            customerState == "PENDING" -> "AWAIT_CUSTOMER_REVIEW"
            else -> "CANDIDATE_FOR_HUMAN_SIGNATURE_REVIEW"
        }
        return listOf(
            "LOCAL FICTIONAL VISIT PACKET - NEVER SUBMITTED",
            "BU-03 / QARAIN Visits",
            "Visit, evidence and acknowledgement references withheld; no customer identity collected.",
            "Task category: $task; claimed work state: $state (not verified).",
            "Claimed evidence: $evidenceType; scope: $evidenceScope (not inspected).",
            "Claimed customer response: $customerState; scope: $customerScope (not authenticated).",
            "Human review decision: $decision.",
            "No actual customer signature, consent, completed work or evidence authenticity established.",
            "No live service system, media capture, storage, transmission, customer contact or closure."
        ).joinToString("\n")
    }
}
