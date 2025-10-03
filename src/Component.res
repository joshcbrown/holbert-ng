open Signatures
module type PORTS = {
  type t
  let combine: (t, t) => t
  let empty: t
}
module Ports = (Term: TERM, Judgment: JUDGMENT with module Term := Term) => {
  module Rule = Rule.Make(Term, Judgment)
  type t = {facts: Dict.t<Rule.t>, ruleStyle: option<RuleView.style>}
  let empty = {facts: Dict.make(), ruleStyle: None}
  let combine = (p1, p2) => {
    let facts = Dict.copy(p1.facts)->Dict.assign(p2.facts)
    let ruleStyle = p2.ruleStyle->Option.mapOr(p1.ruleStyle, x => Some(x))
    {facts, ruleStyle}
  }
}

module type COMPONENT = {
  module Ports: PORTS
  type state
  type props = {
    content: state,
    imports: Ports.t,
    /* onLoad: (~exports: Ports.t, ~string: string=?) => unit, */
    onChange: (state, ~exports: Ports.t=?) => unit,
  }
  let serialise: state => string
  let deserialise: (string, ~imports: Ports.t) => result<(state, Ports.t), string>
  let make: props => React.element
}
