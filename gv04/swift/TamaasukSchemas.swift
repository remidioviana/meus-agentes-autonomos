import Foundation

struct GV04Field {
    let name: String
    let type: String
    let required: Bool
    let classification: String
}
struct GV04Schema {
    let department: String
    let version: Int
    let fields: [GV04Field]
}
struct GV04Mapping {
    let source: String
    let target: String
    let scope: String
    let consent: Bool
}
struct GV04Finding: Equatable {
    let code: String
    let source: String
    let target: String
    init(_ code: String, _ source: String = "", _ target: String = "") {
        self.code = code; self.source = source; self.target = target
    }
}
struct GV04Review {
    let status: String
    let findings: [GV04Finding]
    let humanReviewRequired = true
    let dataTransferred = false
}
enum TamaasukSchemas {
    private static let types: Set<String> = ["STRING", "INTEGER", "BOOLEAN", "DATE"]
    private static let classifications: [String: Int] = ["PUBLIC": 0, "INTERNAL": 1, "RESTRICTED": 2]
    private static func identifier(_ value: String) -> Bool {
        value.range(of: "^[A-Za-z][A-Za-z0-9_]{0,39}$", options: .regularExpression) != nil
    }
    private static func valid(_ schema: GV04Schema) -> Bool {
        identifier(schema.department) && schema.version > 0 && (1...100).contains(schema.fields.count) &&
        Set(schema.fields.map { $0.name }).count == schema.fields.count &&
        schema.fields.allSatisfy { identifier($0.name) && types.contains($0.type) && classifications[$0.classification] != nil }
    }
    static func inspect(source: GV04Schema, target: GV04Schema, mappings: [GV04Mapping], approvedScopes: Set<String>, expectedSourceVersion: Int, expectedTargetVersion: Int) -> GV04Review {
        guard valid(source), valid(target), mappings.count <= 100,
              mappings.allSatisfy({ identifier($0.source) && identifier($0.target) && identifier($0.scope) }),
              Set(mappings.map { $0.source }).count == mappings.count,
              Set(mappings.map { $0.target }).count == mappings.count,
              approvedScopes.allSatisfy({ identifier($0) }), expectedSourceVersion > 0, expectedTargetVersion > 0 else {
            return GV04Review(status: "INVALID_INPUT", findings: [GV04Finding("INVALID_INPUT")])
        }
        guard source.version == expectedSourceVersion && target.version == expectedTargetVersion else {
            return GV04Review(status: "BLOCKED", findings: [GV04Finding("VERSION_MISMATCH")])
        }
        let sourceFields = Dictionary(uniqueKeysWithValues: source.fields.map { ($0.name, $0) })
        let targetFields = Dictionary(uniqueKeysWithValues: target.fields.map { ($0.name, $0) })
        var findings: [GV04Finding] = []
        for mapping in mappings {
            let src = sourceFields[mapping.source]
            let dst = targetFields[mapping.target]
            if src == nil { findings.append(GV04Finding("UNKNOWN_SOURCE", mapping.source, mapping.target)) }
            if dst == nil { findings.append(GV04Finding("UNKNOWN_TARGET", mapping.source, mapping.target)) }
            if !mapping.consent || !approvedScopes.contains(mapping.scope) { findings.append(GV04Finding("SCOPE_OR_CONSENT_DENIED", mapping.source, mapping.target)) }
            if let src = src, let dst = dst {
                if src.type != dst.type { findings.append(GV04Finding("TYPE_MISMATCH", mapping.source, mapping.target)) }
                if classifications[src.classification]! > classifications[dst.classification]! { findings.append(GV04Finding("CLASSIFICATION_DOWNGRADE", mapping.source, mapping.target)) }
                if dst.required && !src.required { findings.append(GV04Finding("REQUIREDNESS_MISMATCH", mapping.source, mapping.target)) }
            }
        }
        let mappedTargets = Set(mappings.map { $0.target })
        for field in target.fields where field.required && !mappedTargets.contains(field.name) {
            findings.append(GV04Finding("REQUIRED_TARGET_UNMAPPED", "", field.name))
        }
        return GV04Review(status: findings.isEmpty ? "REVIEW_REQUIRED" : "BLOCKED", findings: findings)
    }
}
