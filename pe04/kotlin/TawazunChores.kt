package ai.dubai.personal.tawazun

/** PE-04: local-only, consent-gated, deterministic chore negotiation draft. No account or network access. */
data class Person(val id: String, val capacityMinutes: Int, val optedIn: Boolean)
data class Chore(val id: String, val minutes: Int, val eligiblePeople: List<String>)
data class Proposal(val choreId: String, val personId: String)
data class PlanResult(
    val status: String,
    val proposals: List<Proposal>,
    val concerns: List<String>,
    val humanReviewRequired: Boolean = true,
    val externalActionExecuted: Boolean = false
)
object TawazunChores {
    private val idPattern = Regex("[A-Za-z0-9_-]{1,32}")
    fun draft(people: List<Person>, chores: List<Chore>): PlanResult {
        fun reject(reason: String) = PlanResult("BLOCKED", emptyList(), listOf(reason))
        if (people.size !in 2..8 || chores.size !in 1..20) return reject("Input count outside bounded limits")
        if (people.any { !idPattern.matches(it.id) || it.capacityMinutes !in 1..600 } ||
            people.map { it.id }.toSet().size != people.size) return reject("Invalid or duplicate participant")
        if (chores.any { !idPattern.matches(it.id) || it.minutes !in 1..240 || it.eligiblePeople.isEmpty() ||
                it.eligiblePeople.size != it.eligiblePeople.toSet().size } ||
            chores.map { it.id }.toSet().size != chores.size) return reject("Invalid or duplicate chore")
        if (people.any { !it.optedIn }) return reject("All listed participants must opt in")
        val known = people.map { it.id }.toSet()
        if (chores.any { !known.containsAll(it.eligiblePeople) }) return reject("Unknown eligible participant")
        val load = people.associate { it.id to 0 }.toMutableMap()
        val capacities = people.associate { it.id to it.capacityMinutes }
        val proposals = mutableListOf<Proposal>()
        // Hardest tasks first; stable IDs make results independent of input ordering.
        for (chore in chores.sortedWith(compareByDescending<Chore> { it.minutes }.thenBy { it.id })) {
            val choices = chore.eligiblePeople.filter { load.getValue(it) + chore.minutes <= capacities.getValue(it) }
            if (choices.isEmpty()) return PlanResult("REVIEW_REQUIRED", emptyList(),
                listOf("No capacity for ${chore.id}; manual negotiation needed"))
            val chosen = choices.minWith(compareBy<String> {
                load.getValue(it).toDouble() / capacities.getValue(it).toDouble()
            }.thenBy { it })
            proposals.add(Proposal(chore.id, chosen))
            load[chosen] = load.getValue(chosen) + chore.minutes
        }
        return PlanResult("DRAFT_REQUIRES_CONFIRMATION", proposals.sortedBy { it.choreId }, emptyList())
    }
}
