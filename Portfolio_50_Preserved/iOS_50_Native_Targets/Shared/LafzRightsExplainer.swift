import Foundation

/// AE-18: English cue spotting in fictional notices, not legal interpretation or advice.
enum LafzRightsExplainer {
    enum Cue: String { case obligation = "OBLIGATION", permission = "PERMISSION", timeReference = "TIME_REFERENCE", exception = "EXCEPTION" }
    struct Finding {
        let cue: Cue
        let explanation: String
        let reviewQuestion: String
    }
    struct Report { let findings: [Finding]; let disclosure: String }
    enum Failure: Error { case fictionalConfirmationRequired, invalidLength, controlCharacter }
    static let disclosure = "Fictional English text only. Cue detection is not legal advice, rights assessment, deadline verification, translation, or a government service. No input is sent or saved to storage by this feature. Ask a qualified human before acting."
    private static let vocabulary: [(Cue, Set<String>, String, String)] = [
        (.obligation, ["must", "shall"], "Possible obligation wording detected; meaning is unverified.", "Does this wording describe a required action? Confirm with a qualified reviewer."),
        (.permission, ["may", "can"], "Possible permission wording detected; meaning is unverified.", "Is this a permission, possibility, or something else in context?"),
        (.timeReference, ["within", "before", "after", "until"], "Possible time-condition wording detected; no deadline calculated.", "What date or event starts the period, and who can verify it?"),
        (.exception, ["unless", "except"], "Possible exception wording detected; scope is unverified.", "Which conditions might change the statement, if any?")
    ]
    static func analyze(_ notice: String, confirmedFictional: Bool) throws -> Report {
        guard confirmedFictional else { throw Failure.fictionalConfirmationRequired }
        guard !notice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, notice.utf16.count <= 1500 else { throw Failure.invalidLength }
        guard !notice.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else { throw Failure.controlCharacter }
        let tokens = Set(notice.lowercased().split(whereSeparator: { !$0.isLetter }).map(String.init))
        let findings = vocabulary.compactMap { (cue, words, explanation, question) -> Finding? in
            words.isDisjoint(with: tokens) ? nil : Finding(cue: cue, explanation: explanation, reviewQuestion: question)
        }
        return Report(findings: findings, disclosure: disclosure)
    }
}
