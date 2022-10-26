type numberConfig<'a> = {
  min: 'a,
  max: 'a,
  initial: 'a,
  step: 'a,
}

type stringConfig = string

type boolConfig = bool

type demoUnitProps<'b> = {
  general:  (Belt.Map.String.key, ~options: array<(string, 'b)>=?, 'b) => 'b,
  string: 'a. (Belt.Map.String.key, ~options: array<(string, 'a)>=?, 'a) => 'a,
  int: (string, numberConfig<int>) => int,
  float: (string, numberConfig<float>) => float,
  bool: (string, boolConfig) => bool,
}
