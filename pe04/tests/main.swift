import Foundation
let people = [TawazunPerson(id:"Ada",capacityMinutes:120,optedIn:true), TawazunPerson(id:"Bo",capacityMinutes:120,optedIn:true)]
let chores = [TawazunChore(id:"cook",minutes:60,eligiblePeople:["Ada","Bo"]), TawazunChore(id:"wash",minutes:30,eligiblePeople:["Ada","Bo"])]
func test(_ label:String, _ p:[TawazunPerson] = people, _ c:[TawazunChore] = chores,
          _ expected:String = "BLOCKED", _ extra:((TawazunPlan)->Void)? = nil) {
    let result = TawazunChores.draft(people:p,chores:c)
    precondition(result.status == expected,"\(label): \(result.status)")
    precondition(result.humanReviewRequired && !result.externalActionExecuted)
    extra?(result)
    print("PASS PE-04 Swift: \(label)")
}
test("valid balanced",people,chores,"DRAFT_REQUIRES_CONFIRMATION") { r in
    precondition(r.proposals == [TawazunProposal(choreId:"cook",personId:"Ada"), TawazunProposal(choreId:"wash",personId:"Bo")])
}
test("order invariant",people,Array(chores.reversed()),"DRAFT_REQUIRES_CONFIRMATION") { r in
    precondition(r.proposals == TawazunChores.draft(people:people,chores:chores).proposals)
}
test("consent missing",people.map { TawazunPerson(id:$0.id,capacityMinutes:$0.capacityMinutes,optedIn:false) })
test("duplicate people",[people[0],people[0]])
test("duplicate chore",people,[chores[0],chores[0]])
test("unknown eligible",people,[TawazunChore(id:"x",minutes:1,eligiblePeople:["Ghost"])])
test("duplicate eligible",people,[TawazunChore(id:"x",minutes:1,eligiblePeople:["Ada","Ada"])])
test("zero capacity",[TawazunPerson(id:"Ada",capacityMinutes:0,optedIn:true),people[1]])
test("negative duration",people,[TawazunChore(id:"x",minutes:-1,eligiblePeople:["Ada"])])
test("oversized duration",people,[TawazunChore(id:"x",minutes:241,eligiblePeople:["Ada"])])
test("injection id",people,[TawazunChore(id:"x;DELETE",minutes:1,eligiblePeople:["Ada"])])
test("unicode id",[TawazunPerson(id:"أحمد",capacityMinutes:120,optedIn:true),people[1]])
test("empty eligible",people,[TawazunChore(id:"x",minutes:1,eligiblePeople:[])])
test("too many chores",people,(1...21).map { TawazunChore(id:"c\($0)",minutes:1,eligiblePeople:["Ada"]) })
test("capacity exhausted",[TawazunPerson(id:"Ada",capacityMinutes:10,optedIn:true),TawazunPerson(id:"Bo",capacityMinutes:10,optedIn:true)],
     [TawazunChore(id:"x",minutes:20,eligiblePeople:["Ada","Bo"])],"REVIEW_REQUIRED") { r in
    precondition(r.proposals.isEmpty)
}
test("eligibility respected",people,[TawazunChore(id:"x",minutes:10,eligiblePeople:["Bo"])],"DRAFT_REQUIRES_CONFIRMATION") { r in
    precondition(r.proposals.first?.personId == "Bo")
}
