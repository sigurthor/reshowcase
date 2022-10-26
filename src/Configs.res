type numberConfig<'a> = {
  min: 'a,
  max: 'a,
  initial: 'a,
  step: 'a,
}

type stringConfig = string

type boolConfig = bool

type demoUnitProps = {
  obj: 'a. (Belt.Map.String.key, ~options: array<(string, 'a)>=?, 'a) => 'a,
  string:  (Belt.Map.String.key, ~options: array<(string, string)>=?, string) => string,
  int: (string, numberConfig<int>) => int,
  float: (string, numberConfig<float>) => float,
  bool: (string, boolConfig) => bool,
}
