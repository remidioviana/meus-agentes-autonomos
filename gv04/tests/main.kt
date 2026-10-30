import dubai.gv04.*

fun main() {
    var assertions = 0
    fun checkCase(name: String, actual: Review, status: String, codes: List<String>) {
        check(actual.status == status) { "$name status: ${actual.status}" }; assertions++
        check(actual.findings.map { it.code } == codes) { "$name codes: ${actual.findings}" }; assertions++
        check(actual.humanReviewRequired && !actual.dataTransferred) { "$name side effect invariant" }; assertions++
    }
    val source = Schema("DeptA", 2, listOf(FieldDef("personId", "STRING", true, "INTERNAL")))
    val target = Schema("DeptB", 3, listOf(FieldDef("citizenKey", "STRING", true, "INTERNAL")))
    val mapping = FieldMapping("personId", "citizenKey", "Review", true)
    fun inspect(s: Schema=source, t: Schema=target, m: List<FieldMapping> = listOf(mapping), scopes: Set<String> = setOf("Review"), sv: Int=2, tv: Int=3) = TamaasukSchemas.inspect(s,t,m,scopes,sv,tv)
    checkCase("valid", inspect(), "REVIEW_REQUIRED", emptyList())
    checkCase("no consent", inspect(m=listOf(mapping.copy(consent=false))), "BLOCKED", listOf("SCOPE_OR_CONSENT_DENIED"))
    checkCase("unknown scope", inspect(scopes=emptySet()), "BLOCKED", listOf("SCOPE_OR_CONSENT_DENIED"))
    checkCase("type mismatch", inspect(t=target.copy(fields=listOf(FieldDef("citizenKey", "INTEGER", true, "INTERNAL")))), "BLOCKED", listOf("TYPE_MISMATCH"))
    checkCase("downgrade", inspect(t=target.copy(fields=listOf(FieldDef("citizenKey", "STRING", true, "PUBLIC")))), "BLOCKED", listOf("CLASSIFICATION_DOWNGRADE"))
    checkCase("required mismatch", inspect(s=source.copy(fields=listOf(FieldDef("personId", "STRING", false, "INTERNAL")))), "BLOCKED", listOf("REQUIREDNESS_MISMATCH"))
    checkCase("missing target", inspect(m=emptyList()), "BLOCKED", listOf("REQUIRED_TARGET_UNMAPPED"))
    checkCase("unknown source", inspect(m=listOf(mapping.copy(source="other"))), "BLOCKED", listOf("UNKNOWN_SOURCE"))
    checkCase("unknown target", inspect(m=listOf(mapping.copy(target="other"))), "BLOCKED", listOf("UNKNOWN_TARGET", "REQUIRED_TARGET_UNMAPPED"))
    checkCase("stale", inspect(sv=1), "BLOCKED", listOf("VERSION_MISMATCH"))
    checkCase("duplicate mappings", inspect(m=listOf(mapping,mapping)), "INVALID_INPUT", listOf("INVALID_INPUT"))
    checkCase("invalid field", inspect(s=source.copy(fields=listOf(FieldDef("bad field", "STRING", true, "INTERNAL")))), "INVALID_INPUT", listOf("INVALID_INPUT"))
    checkCase("unknown type", inspect(s=source.copy(fields=listOf(FieldDef("personId", "FLOAT", true, "INTERNAL")))), "INVALID_INPUT", listOf("INVALID_INPUT"))
    checkCase("bad version", inspect(s=source.copy(version=0)), "INVALID_INPUT", listOf("INVALID_INPUT"))
    checkCase("scope invalid", inspect(scopes=setOf("bad scope")), "INVALID_INPUT", listOf("INVALID_INPUT"))
    checkCase("unmapped optional", inspect(t=target.copy(fields=target.fields+FieldDef("notes", "STRING", false, "PUBLIC"))), "REVIEW_REQUIRED", emptyList())
    println("GV-04 Kotlin PASS $assertions/48 assertions")
}
