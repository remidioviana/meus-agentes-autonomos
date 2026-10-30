package ai.dubai.gov

/** Local fictional research inputs ONLY. No real UAE government data, calls, or approvals. */
data class GovernmentCase(
    val evidence: List<String>,
    val indicators: Map<String, String>,
    val values: List<Double>,
    val note: String,
    val syntheticConfirmed: Boolean
)
data class GovernmentFinding(
    val missionId: String,
    val missionName: String,
    val status: String,
    val concerns: List<String>,
    val externalActionExecuted: Boolean = false,
    val humanReviewRequired: Boolean = true
)
internal interface GovernmentMission {
    val id: String
    val name: String
    fun evaluate(input: GovernmentCase): GovernmentFinding
}
internal object SyntheticGuard {
    fun refusal(id: String, name: String, input: GovernmentCase): GovernmentFinding? {
        if (!input.syntheticConfirmed) return GovernmentFinding(id, name, "BLOCKED", listOf("Fictional-only confirmation required."))
        if (input.values.size != 3 || input.values.any { !it.isFinite() } ||
            input.note.length > 500 || input.evidence.size > 30 ||
            input.evidence.any { it.isBlank() || it.length > 100 } ||
            input.indicators.size > 30 ||
            input.indicators.any { it.key.length > 80 || it.value.length > 100 })
            return GovernmentFinding(id, name, "INVALID_SYNTHETIC_CASE", listOf("Input shape or bounds invalid."))
        return null
    }
    fun finding(id: String, name: String, concerns: List<String>): GovernmentFinding =
        GovernmentFinding(id, name,
            if (concerns.isEmpty()) "NO_ISSUE_IN_SYNTHETIC_SAMPLE" else "REVIEW_REQUIRED",
            if (concerns.isEmpty()) listOf("Limited synthetic checks found no exception; NOT government validation.") else concerns
        )
}
