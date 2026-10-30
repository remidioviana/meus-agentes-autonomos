package ai.dubai.agents

import java.util.Locale

/** AE-18: English cue spotting in fictional notices, not legal interpretation or advice. */
object LafzRightsExplainer {
    enum class Cue { OBLIGATION, PERMISSION, TIME_REFERENCE, EXCEPTION }
    data class Finding(val cue: Cue, val explanation: String, val reviewQuestion: String)
    data class Report(val findings: List<Finding>, val disclosure: String)
    const val DISCLOSURE = "Fictional English text only. Cue detection is not legal advice, rights assessment, deadline verification, translation, or a government service. No input is sent or saved to storage by this feature. Ask a qualified human before acting."
    private val vocabulary = listOf(
        Triple(Cue.OBLIGATION, setOf("must", "shall"), "Does this wording describe a required action? Confirm with a qualified reviewer."),
        Triple(Cue.PERMISSION, setOf("may", "can"), "Is this a permission, possibility, or something else in context?"),
        Triple(Cue.TIME_REFERENCE, setOf("within", "before", "after", "until"), "What date or event starts the period, and who can verify it?"),
        Triple(Cue.EXCEPTION, setOf("unless", "except"), "Which conditions might change the statement, if any?")
    )
    private val explanations = mapOf(
        Cue.OBLIGATION to "Possible obligation wording detected; meaning is unverified.",
        Cue.PERMISSION to "Possible permission wording detected; meaning is unverified.",
        Cue.TIME_REFERENCE to "Possible time-condition wording detected; no deadline calculated.",
        Cue.EXCEPTION to "Possible exception wording detected; scope is unverified."
    )
    fun analyze(notice: String, confirmedFictional: Boolean): Report {
        require(confirmedFictional) { "Confirm that the text is fictional" }
        require(notice.isNotBlank() && notice.length <= 1500) { "Enter 1–1500 characters" }
        require(notice.none { it.isISOControl() }) { "Control characters are not supported" }
        val tokens = notice.lowercase(Locale.ROOT).split(Regex("[^\\p{L}]+"))
            .filter { it.isNotEmpty() }.toSet()
        val findings = vocabulary.filter { (_, words, _) -> words.any(tokens::contains) }
            .map { (cue, _, question) -> Finding(cue, explanations.getValue(cue), question) }
        return Report(findings, DISCLOSURE)
    }
}
