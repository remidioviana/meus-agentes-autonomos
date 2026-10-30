import ai.dubai.bu04.RasdAssets as R

fun main() {
    val now = 1_800_000_000L
    val temp = R.Rule("A1", R.Metric.TEMPERATURE_C, 10.0, 30.0, "C", "Reviewer A")
    val vib = R.Rule("B2", R.Metric.VIBRATION_MM_S, 0.0, 5.0, "mm/s", "Reviewer B")
    fun t(value: Double = 20.0, at: Long = now, authorized: Boolean = true,
          evidence: String = "E1", unit: String = "C", asset: String = "A1") =
        R.Reading(asset, R.Metric.TEMPERATURE_C, value, unit, at, authorized, evidence)
    fun v(value: Double = 4.0, evidence: String = "E2") =
        R.Reading("B2", R.Metric.VIBRATION_MM_S, value, "mm/s", now, true, evidence)
    var checks = 0
    fun expect(name: String, expected: R.Status, rules: List<R.Rule> = listOf(temp),
               readings: List<R.Reading> = listOf(t()), findings: Int? = null) {
        val actual = R.evaluate(rules, readings, now)
        check(actual.status == expected) { "$name expected $expected got ${actual.status}: ${actual.explanation}" }
        if (findings != null) check(actual.findings.size == findings) { "$name findings mismatch" }
        check(actual.disclosure.contains("No dispatch"))
        checks++
        println("PASS $name")
    }
    expect("high_temp", R.Status.REVIEW_REQUIRED, readings = listOf(t(31.0)), findings = 1)
    expect("normal_temp", R.Status.NO_EXCEPTION, findings = 0)
    expect("min_inclusive", R.Status.NO_EXCEPTION, readings = listOf(t(10.0)))
    expect("max_inclusive", R.Status.NO_EXCEPTION, readings = listOf(t(30.0)))
    expect("low_temp", R.Status.REVIEW_REQUIRED, readings = listOf(t(9.0)), findings = 1)
    expect("high_vibration", R.Status.REVIEW_REQUIRED, listOf(vib), listOf(v(5.1)), 1)
    expect("normal_vibration", R.Status.NO_EXCEPTION, listOf(vib), listOf(v(5.0)))
    expect("two_findings", R.Status.REVIEW_REQUIRED, listOf(temp,vib), listOf(v(7.0),t(35.0)), 2)
    expect("unauthorized", R.Status.BLOCKED, readings = listOf(t(35.0, authorized=false)), findings = 0)
    expect("stale", R.Status.BLOCKED, readings = listOf(t(at=now-86_401)))
    expect("stale_boundary", R.Status.NO_EXCEPTION, readings = listOf(t(at=now-86_400)))
    expect("future", R.Status.BLOCKED, readings = listOf(t(at=now+301)))
    expect("future_boundary", R.Status.NO_EXCEPTION, readings = listOf(t(at=now+300)))
    expect("missing_rule", R.Status.BLOCKED, readings = listOf(t(asset="Other")))
    expect("duplicate_rule", R.Status.INVALID_INPUT, rules = listOf(temp,temp))
    expect("duplicate_evidence", R.Status.INVALID_INPUT, readings = listOf(t(),t()))
    expect("nan", R.Status.INVALID_INPUT, readings = listOf(t(Double.NaN)))
    expect("infinite", R.Status.INVALID_INPUT, readings = listOf(t(Double.POSITIVE_INFINITY)))
    expect("wrong_unit", R.Status.INVALID_INPUT, readings = listOf(t(unit="F")))
    expect("bad_threshold", R.Status.INVALID_INPUT, rules = listOf(temp.copy(minimum=30.0)))
    expect("blank_reviewer", R.Status.INVALID_INPUT, rules = listOf(temp.copy(suggestedReviewer=" ")))
    expect("missing_evidence", R.Status.INVALID_INPUT, readings = listOf(t(evidence="")))
    expect("bad_asset", R.Status.INVALID_INPUT, readings = listOf(t(asset="bad asset")))
    expect("no_readings", R.Status.INVALID_INPUT, readings = emptyList())
    expect("no_rules", R.Status.INVALID_INPUT, rules = emptyList())
    expect("too_many", R.Status.INVALID_INPUT, readings = (1..101).map { t(evidence="E$it") })
    check(R.evaluate(listOf(temp), listOf(t()), Long.MAX_VALUE).status == R.Status.INVALID_INPUT)
    checks++
    println("PASS clock_overflow")
    val review = R.evaluate(listOf(temp,vib), listOf(v(6.0),t(40.0)), now)
    check(review.findings.map { it.assetId } == listOf("A1", "B2"))
    check(review.findings[0].suggestedReviewer == "Reviewer A")
    checks++
    println("PASS stable_sort_and_owner")
    println("KOTLIN PASS $checks/$checks")
}
