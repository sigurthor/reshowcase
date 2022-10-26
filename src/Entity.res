type rec t<'a> = Demo(Configs.demoUnitProps<'a> => React.element) | Category(Js.Dict.t<t<string>>)
