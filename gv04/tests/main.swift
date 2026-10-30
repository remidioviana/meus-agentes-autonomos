import Foundation

@main struct Tests {
static func main() {
    var assertions = 0
    func checkCase(_ name: String, _ actual: GV04Review, _ status: String, _ codes: [String]) {
        precondition(actual.status == status, "\(name) status: \(actual.status)"); assertions += 1
        precondition(actual.findings.map { $0.code } == codes, "\(name) codes"); assertions += 1
        precondition(actual.humanReviewRequired && !actual.dataTransferred, "\(name) side effect"); assertions += 1
    }
    let source = GV04Schema(department: "DeptA", version: 2, fields: [GV04Field(name: "personId", type: "STRING", required: true, classification: "INTERNAL")])
    let target = GV04Schema(department: "DeptB", version: 3, fields: [GV04Field(name: "citizenKey", type: "STRING", required: true, classification: "INTERNAL")])
    let mapping = GV04Mapping(source: "personId", target: "citizenKey", scope: "Review", consent: true)
    func inspect(_ s: GV04Schema? = nil, _ t: GV04Schema? = nil, _ m: [GV04Mapping]? = nil, _ scopes: Set<String>? = nil, _ sv: Int = 2, _ tv: Int = 3) -> GV04Review {
        TamaasukSchemas.inspect(source: s ?? source, target: t ?? target, mappings: m ?? [mapping], approvedScopes: scopes ?? ["Review"], expectedSourceVersion: sv, expectedTargetVersion: tv)
    }
    checkCase("valid", inspect(), "REVIEW_REQUIRED", [])
    checkCase("no consent", inspect(nil,nil,[GV04Mapping(source: "personId", target: "citizenKey", scope: "Review", consent: false)]), "BLOCKED", ["SCOPE_OR_CONSENT_DENIED"])
    checkCase("unknown scope", inspect(nil,nil,nil,[]), "BLOCKED", ["SCOPE_OR_CONSENT_DENIED"])
    checkCase("type mismatch", inspect(nil,GV04Schema(department: "DeptB", version: 3, fields: [GV04Field(name: "citizenKey", type: "INTEGER", required: true, classification: "INTERNAL")])), "BLOCKED", ["TYPE_MISMATCH"])
    checkCase("downgrade", inspect(nil,GV04Schema(department: "DeptB", version: 3, fields: [GV04Field(name: "citizenKey", type: "STRING", required: true, classification: "PUBLIC")])), "BLOCKED", ["CLASSIFICATION_DOWNGRADE"])
    checkCase("required mismatch", inspect(GV04Schema(department: "DeptA", version: 2, fields: [GV04Field(name: "personId", type: "STRING", required: false, classification: "INTERNAL")])), "BLOCKED", ["REQUIREDNESS_MISMATCH"])
    checkCase("missing target", inspect(nil,nil,[]), "BLOCKED", ["REQUIRED_TARGET_UNMAPPED"])
    checkCase("unknown source", inspect(nil,nil,[GV04Mapping(source: "other", target: "citizenKey", scope: "Review", consent: true)]), "BLOCKED", ["UNKNOWN_SOURCE"])
    checkCase("unknown target", inspect(nil,nil,[GV04Mapping(source: "personId", target: "other", scope: "Review", consent: true)]), "BLOCKED", ["UNKNOWN_TARGET", "REQUIRED_TARGET_UNMAPPED"])
    checkCase("stale", inspect(nil,nil,nil,nil,1), "BLOCKED", ["VERSION_MISMATCH"])
    checkCase("duplicate mappings", inspect(nil,nil,[mapping,mapping]), "INVALID_INPUT", ["INVALID_INPUT"])
    checkCase("invalid field", inspect(GV04Schema(department: "DeptA", version: 2, fields: [GV04Field(name: "bad field", type: "STRING", required: true, classification: "INTERNAL")])), "INVALID_INPUT", ["INVALID_INPUT"])
    checkCase("unknown type", inspect(GV04Schema(department: "DeptA", version: 2, fields: [GV04Field(name: "personId", type: "FLOAT", required: true, classification: "INTERNAL")])), "INVALID_INPUT", ["INVALID_INPUT"])
    checkCase("bad version", inspect(GV04Schema(department: "DeptA", version: 0, fields: source.fields)), "INVALID_INPUT", ["INVALID_INPUT"])
    checkCase("scope invalid", inspect(nil,nil,nil,["bad scope"]), "INVALID_INPUT", ["INVALID_INPUT"])
    checkCase("unmapped optional", inspect(nil,GV04Schema(department: "DeptB", version: 3, fields: target.fields + [GV04Field(name: "notes", type: "STRING", required: false, classification: "PUBLIC")])), "REVIEW_REQUIRED", [])
    print("GV-04 Swift PASS \(assertions)/48 assertions")
}
}
