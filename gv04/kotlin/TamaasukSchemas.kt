package dubai.gv04

data class FieldDef(val name: String, val type: String, val required: Boolean, val classification: String)
data class Schema(val department: String, val version: Int, val fields: List<FieldDef>)
data class FieldMapping(val source: String, val target: String, val scope: String, val consent: Boolean)
data class Finding(val code: String, val source: String = "", val target: String = "")
data class Review(val status: String, val findings: List<Finding>, val humanReviewRequired: Boolean = true, val dataTransferred: Boolean = false)

object TamaasukSchemas {
    private val identifier = Regex("[A-Za-z][A-Za-z0-9_]{0,39}")
    private val types = setOf("STRING", "INTEGER", "BOOLEAN", "DATE")
    private val classifications = mapOf("PUBLIC" to 0, "INTERNAL" to 1, "RESTRICTED" to 2)

    private fun valid(schema: Schema): Boolean =
        identifier.matches(schema.department) && schema.version > 0 &&
        schema.fields.size in 1..100 &&
        schema.fields.map { it.name }.toSet().size == schema.fields.size &&
        schema.fields.all { identifier.matches(it.name) && it.type in types && it.classification in classifications }

    fun inspect(source: Schema, target: Schema, mappings: List<FieldMapping>, approvedScopes: Set<String>, expectedSourceVersion: Int, expectedTargetVersion: Int): Review {
        if (!valid(source) || !valid(target) || mappings.size > 100 ||
            mappings.any { !identifier.matches(it.source) || !identifier.matches(it.target) || !identifier.matches(it.scope) } ||
            mappings.map { it.source }.toSet().size != mappings.size ||
            mappings.map { it.target }.toSet().size != mappings.size ||
            approvedScopes.any { !identifier.matches(it) } || expectedSourceVersion <= 0 || expectedTargetVersion <= 0) {
            return Review("INVALID_INPUT", listOf(Finding("INVALID_INPUT")))
        }
        if (source.version != expectedSourceVersion || target.version != expectedTargetVersion) {
            return Review("BLOCKED", listOf(Finding("VERSION_MISMATCH")))
        }
        val sourceFields = source.fields.associateBy { it.name }
        val targetFields = target.fields.associateBy { it.name }
        val findings = mutableListOf<Finding>()
        for (mapping in mappings) {
            val src = sourceFields[mapping.source]
            val dst = targetFields[mapping.target]
            if (src == null) findings += Finding("UNKNOWN_SOURCE", mapping.source, mapping.target)
            if (dst == null) findings += Finding("UNKNOWN_TARGET", mapping.source, mapping.target)
            if (!mapping.consent || mapping.scope !in approvedScopes) findings += Finding("SCOPE_OR_CONSENT_DENIED", mapping.source, mapping.target)
            if (src != null && dst != null) {
                if (src.type != dst.type) findings += Finding("TYPE_MISMATCH", mapping.source, mapping.target)
                if (classifications.getValue(src.classification) > classifications.getValue(dst.classification)) findings += Finding("CLASSIFICATION_DOWNGRADE", mapping.source, mapping.target)
                if (dst.required && !src.required) findings += Finding("REQUIREDNESS_MISMATCH", mapping.source, mapping.target)
            }
        }
        val mappedTargets = mappings.map { it.target }.toSet()
        for (field in target.fields) {
            if (field.required && field.name !in mappedTargets) findings += Finding("REQUIRED_TARGET_UNMAPPED", "", field.name)
        }
        return Review(if (findings.isEmpty()) "REVIEW_REQUIRED" else "BLOCKED", findings)
    }
}
