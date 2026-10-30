package ai.dubai.research

import java.time.LocalDate
import java.time.format.DateTimeParseException

/** PE-02: local fictional cancellation-evidence timeline, not an account cancellation tool. */
internal object IthbatCancellationMission : OfflineMission {
    override val descriptor = MissionDescriptor(
        id = "PE-02",
        category = "Personal",
        name = "ITHBAT Cancellation",
        purpose = "Guide provider-specific exit steps and preserve user-confirmed cancellation receipt",
        outcomeMetric = "Unwanted renewals after attempted cancellation",
        criticalRisk = "Unauthorized account actions",
        comparator = "Apple Google and direct merchant subscriptions",
        fieldLabels = listOf(
            "Fictional billing channel: APPLE, GOOGLE_PLAY or DIRECT_MERCHANT",
            "Fictional cancellation request date (YYYY-MM-DD)",
            "Fictional evidence: NONE, RECEIPT:ABC-123 or RECEIPT:ABC-123|CHECKED:YYYY-MM-DD"
        )
    )

    private val receiptPattern = Regex("RECEIPT:([A-Za-z0-9][A-Za-z0-9._-]{2,39})(?:\\|CHECKED:([0-9]{4}-[0-9]{2}-[0-9]{2}))?")
    private val datePattern = Regex("[0-9]{4}-[0-9]{2}-[0-9]{2}")

    private fun parseDate(raw: String): LocalDate? {
        if (!datePattern.matches(raw)) return null
        return try {
            LocalDate.parse(raw).takeIf { it.year in 2000..2100 }
        } catch (_: DateTimeParseException) { null }
    }

    override fun prepareLocalReview(inputs: List<String>, reviewed: Boolean): String {
        if (!reviewed) return "BLOCKED: Explicit fictional-only user review required."
        if (inputs.size != 3 || inputs.any { it.length > 120 || it.any { c -> c.code < 32 || c.code == 127 } })
            return "BLOCKED: Exactly three short printable fictional fields required."
        val channel = inputs[0].trim()
        val guidance = when (channel) {
            "APPLE" -> "Check the official Apple subscription-management instructions; do not assume deleting an app cancels billing."
            "GOOGLE_PLAY" -> "Check the official Google Play subscription-management instructions; uninstalling an app is not cancellation."
            "DIRECT_MERCHANT" -> "Locate the merchant's own official cancellation and receipt instructions; no merchant-specific route is verified here."
            else -> return "BLOCKED: Choose APPLE, GOOGLE_PLAY or DIRECT_MERCHANT; do not enter account credentials."
        }
        val requested = parseDate(inputs[1].trim())
            ?: return "BLOCKED: Enter a valid Gregorian request date (YYYY-MM-DD, 2000-2100)."
        val evidence = inputs[2].trim()
        val receipt = receiptPattern.matchEntire(evidence)
        if (evidence != "NONE" && receipt == null)
            return "BLOCKED: Use NONE or RECEIPT:reference, optionally followed by |CHECKED:YYYY-MM-DD."
        val checked = receipt?.groupValues?.get(2)?.takeIf { it.isNotEmpty() }?.let { raw ->
            parseDate(raw) ?: return "BLOCKED: Invalid Gregorian statement-check date."
        }
        if (checked != null && checked.isBefore(requested))
            return "BLOCKED: A follow-up check cannot predate the fictional request."
        val state = when {
            checked != null -> "FOLLOW_UP_REPORTED"
            receipt != null -> "RECEIPT_REPORTED"
            else -> "REQUEST_RECORDED"
        }
        return listOf(
            "LOCAL FICTIONAL EVIDENCE TIMELINE - NEVER SUBMITTED",
            "PE-02 / ITHBAT Cancellation",
            "Billing channel: $channel",
            "Request date: $requested (user-entered, not independently verified)",
            "Evidence stage: $state (user-reported, NOT provider-verified)",
            "Receipt identifier withheld; its syntax does not establish authenticity.",
            "Next human review: $guidance",
            "Confirm the actual provider status and subsequent statement directly with the provider; a receipt alone does NOT prove cancellation or prevent renewal.",
            "No credentials, account access, provider contact, billing action, storage or transmission. No cancellation success claim."
        ).joinToString("\n")
    }
}
