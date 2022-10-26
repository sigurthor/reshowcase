type rec addFunctions<'a> = {
  addDemo:  (string, Configs.demoUnitProps<'a> => React.element) => unit,
  addCategory: (string, addFunctions<string> => unit) => unit,
}

let demo: (addFunctions<string> => unit) => unit

let start: unit => unit
