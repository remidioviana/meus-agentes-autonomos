import ai.dubai.agents.LafzRightsExplainer as E

private var checks = 0
fun assertCase(value: Boolean) { check(value); checks++ }
fun rejects(text: String, consent: Boolean = true) {
    var rejected = false
    try { E.analyze(text, consent) } catch (_: IllegalArgumentException) { rejected = true }
    assertCase(rejected)
}
fun main() {
    val report = E.analyze("You MUST respond within ten days, unless exempt; you may ask.", true)
    assertCase(report.findings.map { it.cue } == E.Cue.values().toList())
    assertCase(E.analyze("shall", true).findings.single().cue == E.Cue.OBLIGATION)
    assertCase(E.analyze("CAN", true).findings.single().cue == E.Cue.PERMISSION)
    assertCase(E.analyze("after", true).findings.single().cue == E.Cue.TIME_REFERENCE)
    assertCase(E.analyze("except", true).findings.single().cue == E.Cue.EXCEPTION)
    assertCase(E.analyze("maybe", true).findings.isEmpty())
    assertCase(E.analyze("shell", true).findings.isEmpty())
    assertCase(E.analyze("sample notice", true).findings.isEmpty())
    assertCase(E.analyze("must MUST", true).findings.size == 1)
    assertCase(E.analyze("must", true).findings.single().reviewQuestion.contains("reviewer"))
    assertCase(report.disclosure.contains("not legal advice"))
    assertCase(!report.toString().contains("ten days"))
    assertCase(E.analyze("يجب", true).findings.isEmpty())
    assertCase(E.analyze("must", true).findings.single().explanation.contains("unverified"))
    rejects("must", false)
    rejects("")
    rejects("   ")
    rejects("a".repeat(1501))
    rejects("must\nnow")
    assertCase(E.analyze("a".repeat(1500), true).findings.isEmpty())
    println("AE-18 Kotlin: $checks/$checks assertions PASS")
}
