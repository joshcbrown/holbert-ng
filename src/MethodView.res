open Util
open Signatures
open Method
module type METHOD_VIEW = {
  module Term: TERM
  module Judgment: JUDGMENT with module Term := Term
  module Method: PROOF_METHOD with module Term := Term and module Judgment := Judgment
  type props<'a> = {method: Method.t<'a>, scope: array<Term.meta>, ruleStyle: RuleView.style, gen: Term.gen, onChange: (Method.t<'a>, Term.subst) => ()}
  type srProps<'a> = {"proof": 'a, "scope": array<Term.meta>, "ruleStyle": RuleView.style, "gen": Term.gen, "onChange": ('a, Term.subst) => ()}
  let make: (srProps<'a> => React.element) => props<'a> => React.element
}

module DerivationView = (Term: TERM, Judgment: JUDGMENT with module Term := Term) => {
  module Method = Derivation(Term, Judgment)
  type props<'a> = {method: Method.t<'a>, scope: array<Term.meta>, ruleStyle: RuleView.style, gen: Term.gen, onChange: (Method.t<'a>, Term.subst) => ()}
  type srProps<'a> = {"proof": 'a, "scope": array<Term.meta>, "ruleStyle": RuleView.style, "gen": Term.gen, "onChange": ('a, Term.subst) => ()}
  let make = (subRender: srProps<'a> => React.element) => props => {
    <div>
      <b> {React.string("by ")} </b>
      {React.string(props.method.ruleName)}
      <ul>
        {props.method.subgoals
        ->Array.mapWithIndex((sg, i) => {
          <li key={String.make(i)}>
            {React.createElement(
              subRender,
              {"proof": sg, "scope": props.scope, "ruleStyle": props.ruleStyle, "gen": props.gen, "onChange": (newa, subst) => 
                props.onChange(props.method->Method.updateAtKey(i, _ => newa), subst)
              },
            )}
          </li>
        })
        ->React.array}
      </ul>
    </div>
  }
}

module LemmaView = (
  Term: TERM,
  Judgment: JUDGMENT with module Term := Term,
  JudgmentView: JUDGMENT_VIEW with module Term := Term and module Judgment := Judgment,
) => {
  module Method = Lemma(Term, Judgment)
  type props<'a> = {
    method: Method.t<'a>, 
    scope: array<Term.meta>, 
    ruleStyle: RuleView.style, 
    gen: Term.gen, 
    onChange: (Method.t<'a>, Term.subst) => () 
  }
  type srProps<'a> = {
    "proof": 'a, 
    "scope": array<Term.meta>, 
    "ruleStyle": RuleView.style, 
    "gen":Term.gen,
    "onChange": ('a, Term.subst) => ()
  }
  module RuleView = RuleView.Make(Term, Judgment, JudgmentView)
  let make = (subRender: srProps<'a> => React.element) => props => {
    <div>
      <b> {React.string("have ")} </b>
      <RuleView rule={props.method.rule} scope={props.scope} style={props.ruleStyle}>
        {React.null}
      </RuleView>
      {React.createElement(subRender, {
        "proof": props.method.proof, 
        "scope": props.scope, 
        "ruleStyle": props.ruleStyle, 
        "gen": props.gen, 
        "onChange": (proof, subst) => { props.onChange({...props.method, proof}, subst) } 
      })}
      {React.createElement(subRender, {
        "proof": props.method.show, 
        "scope": props.scope, 
        "ruleStyle": props.ruleStyle,
        "gen": props.gen,
        "onChange": (show, subst) => { props.onChange({...props.method, show}, subst) } 
      })}
    </div>
  }
}
module CombineMethodView = (
  Term: TERM,
  Judgment: JUDGMENT with module Term := Term,
  Method1View: METHOD_VIEW with module Term := Term and module Judgment := Judgment,
  Method2View: METHOD_VIEW
    with module Term := Term
    and module Judgment := Judgment
    and type srProps<'a> = Method1View.srProps<'a>,
) => {
  module Method = Combine(Term, Judgment, Method1View.Method, Method2View.Method)
  type props<'a> = {method: Method.t<'a>, scope: array<Term.meta>, ruleStyle: RuleView.style, gen: Term.gen, onChange: (Method.t<'a>, Term.subst) => ()}
  type srProps<'a> = Method1View.srProps<'a>
  let make = (subrender: srProps<'a> => React.element) => props => {
    switch props.method {
    | First(m) =>
      Method1View.make(subrender)({method: m, scope: props.scope, ruleStyle: props.ruleStyle, gen: props.gen, onChange: (n,s) => props.onChange(First(n), s)})
    | Second(m) =>
      Method2View.make(subrender)({method: m, scope: props.scope, ruleStyle: props.ruleStyle, gen: props.gen, onChange: (n,s) => props.onChange(Second(n), s)})
    }
  }
}
