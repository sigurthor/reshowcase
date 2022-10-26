type rec t<'a> = Demo(Configs.demoUnitProps => React.element) | Category(Js.Dict.t<t<string>>)
