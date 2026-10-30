import Foundation

/// PE-04: local-only, consent-gated chore negotiation draft. Never writes to external systems.
struct TawazunPerson { let id: String; let capacityMinutes: Int; let optedIn: Bool }
struct TawazunChore { let id: String; let minutes: Int; let eligiblePeople: [String] }
struct TawazunProposal: Equatable { let choreId: String; let personId: String }
struct TawazunPlan {
    let status: String
    let proposals: [TawazunProposal]
    let concerns: [String]
    let humanReviewRequired = true
    let externalActionExecuted = false
}
enum TawazunChores {
    private static func validID(_ id: String) -> Bool {
        (1...32).contains(id.utf8.count) && id.utf8.allSatisfy {
            (65...90).contains(Int($0)) || (97...122).contains(Int($0)) ||
            (48...57).contains(Int($0)) || $0 == 95 || $0 == 45
        }
    }
    static func draft(people: [TawazunPerson], chores: [TawazunChore]) -> TawazunPlan {
        func reject(_ message: String) -> TawazunPlan { TawazunPlan(status: "BLOCKED", proposals: [], concerns: [message]) }
        guard (2...8).contains(people.count), (1...20).contains(chores.count) else {
            return reject("Input count outside bounded limits")
        }
        guard people.allSatisfy({ validID($0.id) && (1...600).contains($0.capacityMinutes) }),
              Set(people.map(\.id)).count == people.count else { return reject("Invalid or duplicate participant") }
        guard chores.allSatisfy({ validID($0.id) && (1...240).contains($0.minutes) &&
            !$0.eligiblePeople.isEmpty && Set($0.eligiblePeople).count == $0.eligiblePeople.count }),
            Set(chores.map(\.id)).count == chores.count else { return reject("Invalid or duplicate chore") }
        guard people.allSatisfy(\.optedIn) else { return reject("All listed participants must opt in") }
        let capacities = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0.capacityMinutes) })
        guard chores.allSatisfy({ Set($0.eligiblePeople).isSubset(of: Set(capacities.keys)) }) else {
            return reject("Unknown eligible participant")
        }
        var load = Dictionary(uniqueKeysWithValues: people.map { ($0.id, 0) })
        var proposals: [TawazunProposal] = []
        for chore in chores.sorted(by: { $0.minutes == $1.minutes ? $0.id < $1.id : $0.minutes > $1.minutes }) {
            let choices = chore.eligiblePeople.filter { load[$0, default: 0] + chore.minutes <= capacities[$0, default: 0] }
            guard let chosen = choices.min(by: {
                let left = Double(load[$0, default: 0]) / Double(capacities[$0, default: 1])
                let right = Double(load[$1, default: 0]) / Double(capacities[$1, default: 1])
                return left == right ? $0 < $1 : left < right
            }) else {
                return TawazunPlan(status: "REVIEW_REQUIRED", proposals: [],
                    concerns: ["No capacity for \(chore.id); manual negotiation needed"])
            }
            proposals.append(TawazunProposal(choreId: chore.id, personId: chosen))
            load[chosen, default: 0] += chore.minutes
        }
        return TawazunPlan(status: "DRAFT_REQUIRES_CONFIRMATION",
            proposals: proposals.sorted(by: { $0.choreId < $1.choreId }), concerns: [])
    }
}
