open Signatures
module type GOAL_VIEW = {
  module Term: TERM
  module Judgment: JUDGMENT with module Term := Term
  module Method: Method.PROOF_METHOD with module Term := Term and module Judgment := Judgment
  @react.componentWithProps
  let make: (
    ~dict: Dict.t<(Method.t<'a>, Judgment.subst)>,
    ~submit: (Method.t<'a>, Judgment.subst) => unit,
  ) => React.element
}

module DefaultGoalView = (
  Term: TERM,
  Judgment: JUDGMENT with module Term := Term,
  Method: Method.PROOF_METHOD with module Term := Term and module Judgment := Judgment,
): (
  GOAL_VIEW with module Term := Term and module Judgment := Judgment and module Method = Method
) => {
  module Term = Term
  module Judgment = Judgment
  module Method = Method

  let make = (
    ~dict: Dict.t<(Method.t<'a>, Judgment.subst)>,
    ~submit: (Method.t<'a>, Judgment.subst) => unit,
  ) =>
    dict
    ->Dict.toArray
    ->Array.map(((str, (opt, subst))) => {
      <button key=str onClick={_ => submit(opt, subst)}> {React.string(str)} </button>
    })
    ->React.array
}

module EliminationGoalView = (Term: TERM, Judgment: JUDGMENT with module Term := Term) => {
  module Term = Term
  module Judgment = Judgment
  module Method = Method.Elimination(Term, Judgment)
  @react.componentWithProps
  let make = Error("todo")->Result.getExn
}

module Combine = (
  Term: TERM,
  Judgment: JUDGMENT with module Term := Term,
  G1: GOAL_VIEW with module Term := Term and module Judgment := Judgment,
  G2: GOAL_VIEW with module Term := Term and module Judgment := Judgment,
  Method: module type of Method.Combine(Term, Judgment, G1.Method, G2.Method),
) => {
  module Term = Term
  module Judgment = Judgment
  @react.componentWithProps
  let make: 'a = Error("todo")->Result.getExn
}
