package ai.dubai.research

/** Offline, fictional-data-only review. Not an autonomous AI agent. */
internal data class MissionDescriptor(
    val id: String,
    val category: String,
    val name: String,
    val purpose: String,
    val outcomeMetric: String,
    val criticalRisk: String,
    val comparator: String,
    val fieldLabels: List<String>
)
internal interface OfflineMission {
    val descriptor: MissionDescriptor
    fun prepareLocalReview(inputs: List<String>, reviewed: Boolean): String
}
internal object OfflineDraft {
    fun preview(mission: MissionDescriptor, inputs: List<String>, reviewed: Boolean): String {
        if (!reviewed) return "BLOCKED: User must explicitly confirm a fictional-only review."
        if (mission.fieldLabels.size != 3 || inputs.size != 3) return "BLOCKED: Three mission-specific evidence fields required."
        val clean = inputs.map { it.trim() }
        if (clean.any { it.isEmpty() || it.length > 500 || it.any { ch -> ch.code < 32 || ch.code == 127 } })
            return "BLOCKED: Each fictional evidence note must be 1-500 printable characters."
        return buildString {
            appendLine("LOCAL RESEARCH PREVIEW - NEVER SUBMITTED")
            appendLine(mission.id + " / " + mission.name)
            appendLine("Proposed human-reviewed action: " + mission.purpose)
            appendLine("Evidence labels verified locally:")
            mission.fieldLabels.forEachIndexed { index, label ->
                appendLine("  " + (index + 1) + ". " + label + ": PROVIDED (value not displayed)")
            }
            appendLine("Intended outcome to validate, not measured: " + mission.outcomeMetric)
            appendLine("Critical risk to review: " + mission.criticalRisk)
            appendLine("Existing alternative to benchmark: " + mission.comparator)
            appendLine("NOT a legal, medical, financial, accessibility or safety decision.")
            append("No external actions, login, storage, data transfer or agent autonomy.")
        }
    }
}
