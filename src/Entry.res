type rec addFunctions<'a> = {
  addDemo:  (string, Configs.demoUnitProps<'a>=> React.element) => unit,
  addCategory: (string, addFunctions<string> => unit) => unit,
}

let rootMap: Demos.t = Js.Dict.empty()

let demo = (f): unit => {
  let internalAddDemo = (demoName: string, demoUnit: Configs.demoUnitProps<'a> => React.element) => {
    rootMap->Js.Dict.set(demoName, Demo(demoUnit))
  }

  let rec internalAddCategory = (
    categoryName: string,
    func: addFunctions<string> => unit,
    ~prevMap: Demos.t,
  ) => {
    let newCategory = Js.Dict.empty()

    prevMap->Js.Dict.set(categoryName, Category(newCategory))

    let newAddDemo = (demoName: string, demoUnit: Configs.demoUnitProps<'a> => React.element) => {
      newCategory->Js.Dict.set(demoName, Demo(demoUnit))
    }

    let newFunctions = {
      addDemo: newAddDemo,
      addCategory: internalAddCategory(~prevMap=newCategory),
    }

    func(newFunctions)
  }

  let addFunctions = {
    addDemo: internalAddDemo,
    addCategory: internalAddCategory(~prevMap=rootMap),
  }

  f(addFunctions)
}

let start = () =>
  switch ReactDOM.querySelector("#root") {
  | Some(root) => ReactDOM.render(<ReshowcaseUi.App demos=rootMap />, root)
  | None => ()
  }
