package ai.dubai.bu04

/** BU-04 RASD Assets: offline, synthetic, review-only exception proposals. */
object RasdAssets {
    enum class Metric(val unit: String) { TEMPERATURE_C("C"), VIBRATION_MM_S("mm/s") }
    enum class Status { INVALID_INPUT, BLOCKED, REVIEW_REQUIRED, NO_EXCEPTION }
    data class Rule(
        val assetId: String, val metric: Metric, val minimum: Double,
        val maximum: Double, val unit: String, val suggestedReviewer: String
    )
    data class Reading(
        val assetId: String, val metric: Metric, val value: Double,
        val unit: String, val observedAtSeconds: Long,
        val authorizedSource: Boolean, val evidenceId: String
    )
    data class Finding(
        val assetId: String, val metric: Metric, val evidenceId: String,
        val suggestedReviewer: String, val observed: Double,
        val minimum: Double, val maximum: Double
    )
    data class Report(val status: Status, val findings: List<Finding>, val explanation: String) {
        val disclosure: String = "Synthetic offline review only. No dispatch, safety clearance or automatic assignment."
    }
    private val identifier = Regex("[A-Za-z0-9_-]{1,40}")
    private val evidence = Regex("[A-Za-z0-9_-]{1,64}")
    private const val MAX_AGE_SECONDS = 86_400L
    private const val FUTURE_TOLERANCE_SECONDS = 300L

    fun evaluate(rules: List<Rule>, readings: List<Reading>, nowSeconds: Long): Report {
        fun invalid(why: String) = Report(Status.INVALID_INPUT, emptyList(), why)
        fun blocked(why: String) = Report(Status.BLOCKED, emptyList(), why)
        if (nowSeconds <= 0 || nowSeconds > Long.MAX_VALUE - FUTURE_TOLERANCE_SECONDS || rules.isEmpty() || readings.isEmpty() || rules.size > 100 || readings.size > 100)
            return invalid("Expected a positive clock and 1..100 rules and readings")
        val ruleIndex = mutableMapOf<Pair<String, Metric>, Rule>()
        for (rule in rules) {
            if (!identifier.matches(rule.assetId) || rule.unit != rule.metric.unit ||
                !rule.minimum.isFinite() || !rule.maximum.isFinite() || rule.minimum >= rule.maximum ||
                rule.suggestedReviewer.isBlank() || rule.suggestedReviewer.length > 60)
                return invalid("Invalid rule fields")
            val key = rule.assetId to rule.metric
            if (ruleIndex.putIfAbsent(key, rule) != null) return invalid("Duplicate asset/metric rule")
        }
        val seen = mutableSetOf<Triple<String, Metric, String>>()
        val findings = mutableListOf<Finding>()
        for (reading in readings) {
            if (!identifier.matches(reading.assetId) || !evidence.matches(reading.evidenceId) ||
                !reading.value.isFinite() || reading.unit != reading.metric.unit)
                return invalid("Invalid reading fields")
            if (!seen.add(Triple(reading.assetId, reading.metric, reading.evidenceId)))
                return invalid("Duplicate evidence")
            if (!reading.authorizedSource) return blocked("Source authorization not attested")
            if (reading.observedAtSeconds <= 0 || reading.observedAtSeconds > nowSeconds + FUTURE_TOLERANCE_SECONDS ||
                reading.observedAtSeconds < nowSeconds - MAX_AGE_SECONDS)
                return blocked("Reading is stale or beyond allowed clock skew")
            val rule = ruleIndex[reading.assetId to reading.metric]
                ?: return blocked("No approved review rule for asset/metric")
            if (reading.value < rule.minimum || reading.value > rule.maximum) {
                findings.add(Finding(reading.assetId, reading.metric, reading.evidenceId,
                    rule.suggestedReviewer, reading.value, rule.minimum, rule.maximum))
            }
        }
        return if (findings.isEmpty()) Report(Status.NO_EXCEPTION, emptyList(), "No out-of-range readings in supplied batch")
        else Report(Status.REVIEW_REQUIRED, findings.sortedWith(compareBy({ it.assetId }, { it.metric.name }, { it.evidenceId })),
            "Human review required; no task has been assigned")
    }
}
