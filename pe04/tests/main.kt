package ai.dubai.personal.tawazun

fun main() {
    val people = listOf(Person("Ada", 120, true), Person("Bo", 120, true))
    val chores = listOf(Chore("cook", 60, listOf("Ada", "Bo")), Chore("wash", 30, listOf("Ada", "Bo")))
    fun test(label: String, p: List<Person> = people, c: List<Chore> = chores,
             expected: String = "BLOCKED", checkExtra: (PlanResult) -> Unit = {}) {
        val result = TawazunChores.draft(p, c)
        check(result.status == expected) { "$label: ${result.status}" }
        check(result.humanReviewRequired && !result.externalActionExecuted)
        checkExtra(result)
        println("PASS PE-04 Kotlin: $label")
    }
    test("valid balanced", expected="DRAFT_REQUIRES_CONFIRMATION") { r ->
        check(r.proposals == listOf(Proposal("cook", "Ada"), Proposal("wash", "Bo")))
    }
    test("order invariant", c=chores.reversed(), expected="DRAFT_REQUIRES_CONFIRMATION") { r ->
        check(r.proposals == TawazunChores.draft(people, chores).proposals)
    }
    test("consent missing", p=people.map { it.copy(optedIn=false) })
    test("duplicate people", p=listOf(people[0],people[0]))
    test("duplicate chore", c=listOf(chores[0],chores[0]))
    test("unknown eligible", c=listOf(Chore("x", 1, listOf("Ghost"))))
    test("duplicate eligible", c=listOf(Chore("x", 1, listOf("Ada","Ada"))))
    test("zero capacity", p=listOf(people[0].copy(capacityMinutes=0),people[1]))
    test("negative duration", c=listOf(Chore("x", -1, listOf("Ada"))))
    test("oversized duration", c=listOf(Chore("x", 241, listOf("Ada"))))
    test("injection id", c=listOf(Chore("x;DELETE", 1, listOf("Ada"))))
    test("unicode id", p=listOf(Person("أحمد",120,true),people[1]))
    test("empty eligible", c=listOf(Chore("x", 1, emptyList())))
    test("too many chores", c=(1..21).map { Chore("c$it",1,listOf("Ada")) })
    test("capacity exhausted", p=listOf(Person("Ada", 10, true), Person("Bo", 10, true)),
        c=listOf(Chore("x", 20, listOf("Ada","Bo"))),expected="REVIEW_REQUIRED") { r ->
        check(r.proposals.isEmpty())
    }
    test("eligibility respected", c=listOf(Chore("x", 10, listOf("Bo"))),
        expected="DRAFT_REQUIRES_CONFIRMATION") { r -> check(r.proposals.single().personId == "Bo") }
}
