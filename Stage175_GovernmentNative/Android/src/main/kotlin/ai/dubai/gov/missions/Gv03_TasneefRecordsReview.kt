package ai.dubai.gov

/** GV-03: bounded, synthetic retention-policy comparison, NOT a legal retention schedule. */
internal object Gv03_TasneefRecordsReview : GovernmentMission {
    override val id = "GV-03"
    override val name = "TASNEEF Records"
    private val kinds = setOf("correspondence", "finance", "permit")
    private val categories = setOf("short", "medium", "long")

    data class RetentionDraft(
        val proposedCategory: String?,
        val policyReference: String?,
        val policyVersion: String?,
        val disposition: String,
        val blockingReasons: List<String>,
        val humanReviewRequired: Boolean = true,
        val externalActionExecuted: Boolean = false
    )

    fun syntheticExample(issue: Boolean) = GovernmentCase(
        evidence = if (issue) emptyList() else listOf("retention_category", "policy_reference"),
        indicators = mapOf(
            "policy_id" to "DEMO-PUBLIC-001", "policy_version" to "v1",
            "policy_review" to if (issue) "pending" else "reviewed",
            "record_kind" to "correspondence", "rule_correspondence" to "short",
            "submitted_category" to if (issue) "long" else "short",
            "legal_hold" to if (issue) "unknown" else "no", "disposition" to "retain"
        ), values = listOf(1.0, 3.0, 1.0), note = "fictional example", syntheticConfirmed = true
    )

    fun draft(input: GovernmentCase): RetentionDraft {
        SyntheticGuard.refusal(id, name, input)?.let {
            return RetentionDraft(null, null, null, "BLOCKED", it.concerns)
        }
        val i = input.indicators
        val issues = mutableListOf<String>()
        if (!input.evidence.containsAll(listOf("retention_category", "policy_reference")))
            issues.add("Missing source-linked evidence: retention_category or policy_reference")
        val policyId = i["policy_id"]?.takeIf { it.matches(Regex("[A-Za-z0-9._-]{3,64}")) }
        val version = i["policy_version"]?.takeIf { it.matches(Regex("[A-Za-z0-9._-]{1,32}")) }
        if (policyId == null || version == null) issues.add("Missing or invalid synthetic policy reference/version")
        if (i["policy_review"] != "reviewed") issues.add("Policy source not marked reviewed by a qualified human")
        val kind = i["record_kind"]
        if (kind !in kinds) issues.add("Unsupported or missing record kind")
        val policyCategory = kind?.let { i["rule_$it"] }?.takeIf { it in categories }
        if (policyCategory == null) issues.add("No explicit category rule supplied for record kind")
        if (i["submitted_category"] !in categories) issues.add("Missing or invalid submitted category")
        else if (policyCategory != null && i["submitted_category"] != policyCategory)
            issues.add("Submitted category contradicts supplied policy rule")
        val hold = i["legal_hold"]
        if (hold !in setOf("yes", "no")) issues.add("Legal-hold status unknown or invalid")
        val action = i["disposition"]
        if (action !in setOf("retain", "review_for_disposal")) issues.add("Invalid requested disposition")
        val age = input.values[0]
        val minimum = input.values[1]
        val references = input.values[2]
        if (age < 0.0 || minimum < 0.0 || references < 1.0 || references % 1.0 != 0.0)
            issues.add("Invalid age, retention minimum, or policy evidence count")
        if (action == "review_for_disposal") {
            if (hold == "yes") issues.add("Legal hold prohibits disposal review recommendation")
            if (age < minimum) issues.add("Record is younger than the supplied minimum retention period")
        }
        val disposition = if (issues.isEmpty() && action == "review_for_disposal")
            "HUMAN_DISPOSAL_REVIEW_ONLY" else "RETAIN_PENDING_HUMAN_REVIEW"
        return RetentionDraft(policyCategory, policyId, version, disposition, issues)
    }

    override fun evaluate(input: GovernmentCase): GovernmentFinding {
        SyntheticGuard.refusal(id, name, input)?.let { return it }
        val result = draft(input)
        return SyntheticGuard.finding(id, name, result.blockingReasons)
    }
}
