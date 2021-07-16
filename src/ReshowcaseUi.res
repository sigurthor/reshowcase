open Belt

module Color = ReshowcaseUi__Layout.Color
module Gap = ReshowcaseUi__Layout.Gap
module Border = ReshowcaseUi__Layout.Border
module PaddedBox = ReshowcaseUi__Layout.PaddedBox
module Stack = ReshowcaseUi__Layout.Stack
module Sidebar = ReshowcaseUi__Layout.Sidebar
module URLSearchParams = ReshowcaseUi__Bindings.URLSearchParams
module Window = ReshowcaseUi__Bindings.Window
module Array = Js.Array2
module Option = Belt.Option

type entityMap = Belt.MutableMap.String.t<EntryT.entity>

type responsiveMode =
  | Mobile
  | Desktop

let desktopIcon =
  <svg width="32" height="32">
    <g transform="translate(5 8)" fill="none" fillRule="evenodd">
      <rect stroke="currentColor" x="2" width="18" height="13" rx="1" />
      <rect fill="currentColor" y="13" width="22" height="2" rx="1" />
    </g>
  </svg>

let mobileIcon =
  <svg width="32" height="32">
    <g transform="translate(11 7)" fill="none" fillRule="evenodd">
      <rect stroke="currentColor" width="10" height="18" rx="2" />
      <path d="M2 0h6v1a1 1 0 01-1 1H3a1 1 0 01-1-1V0z" fill="currentColor" />
    </g>
  </svg>

let sidebarIcon =
  <svg width="32" height="32">
    <g
      stroke="currentColor"
      strokeWidth="1.5"
      fill="none"
      fillRule="evenodd"
      strokeLinecap="round"
      strokeLinejoin="round">
      <path d="M25.438 17H12.526M19 10.287L12.287 17 19 23.713M8.699 7.513v17.2" />
    </g>
  </svg>

module TopPanel = {
  module Styles = {
    let panel = ReactDOM.Style.make(
      ~display="flex",
      ~justifyContent="flex-end",
      ~borderBottom=Border.default,
      (),
    )

    let buttonGroup = ReactDOM.Style.make(
      ~overflow="hidden",
      ~display="flex",
      ~flexDirection="row",
      ~alignItems="stretch",
      ~borderRadius="7px",
      (),
    )

    let button = ReactDOM.Style.make(
      ~height="32px",
      ~width="48px",
      ~cursor="pointer",
      ~fontSize="14px",
      ~backgroundColor=Color.lightGray,
      ~color=Color.darkGray,
      ~border="none",
      ~margin="0",
      ~padding="0",
      ~display="flex",
      ~alignItems="center",
      ~justifyContent="center",
      (),
    )

    let squareButton = button->ReactDOM.Style.combine(ReactDOM.Style.make(~width="32px", ()))

    let activeButton =
      button->ReactDOM.Style.combine(
        ReactDOM.Style.make(~backgroundColor=Color.blue, ~color=Color.white, ()),
      )

    let middleSection = ReactDOM.Style.make(
      ~display="flex",
      ~flex="1",
      ~justifyContent="center",
      (),
    )

    let rightSection = ReactDOM.Style.make(
      ~width="32px",
      ~display="flex",
      ~justifyContent="flex-end",
      (),
    )
  }

  @react.component
  let make = (
    ~isSidebarHidden: bool,
    ~responsiveMode: responsiveMode,
    ~onRightSidebarToggle: unit => unit,
    ~setResponsiveMode: (responsiveMode => responsiveMode) => unit,
  ) => {
    <div style=Styles.panel>
      <div style=Styles.rightSection />
      <div style=Styles.middleSection>
        <PaddedBox gap=Md>
          <div style=Styles.buttonGroup>
            <button
              title={"Show in desktop mode"}
              style={responsiveMode == Desktop ? Styles.activeButton : Styles.button}
              onClick={event => {
                event->ReactEvent.Mouse.preventDefault
                setResponsiveMode(_ => Desktop)
              }}>
              {desktopIcon}
            </button>
            <button
              title={"Show in mobile mode"}
              style={responsiveMode == Mobile ? Styles.activeButton : Styles.button}
              onClick={event => {
                event->ReactEvent.Mouse.preventDefault
                setResponsiveMode(_ => Mobile)
              }}>
              {mobileIcon}
            </button>
          </div>
        </PaddedBox>
      </div>
      <div style=Styles.rightSection>
        <PaddedBox gap=Md>
          <div style=Styles.buttonGroup>
            <button
              title={isSidebarHidden ? "Show sidebar" : "Hide sidebar"}
              style=Styles.squareButton
              onClick={event => {
                event->ReactEvent.Mouse.preventDefault
                onRightSidebarToggle()
              }}>
              <div
                style={ReactDOM.Style.make(
                  ~transition="200ms ease-in-out transform",
                  ~transform=isSidebarHidden ? "rotate(0)" : "rotate(180deg)",
                  (),
                )}>
                {sidebarIcon}
              </div>
            </button>
          </div>
        </PaddedBox>
      </div>
    </div>
  }
}

let rightSidebarId = "rightSidebar"

module Link = {
  @react.component
  let make = (~href, ~text, ~style=?, ~activeStyle=?) => {
    let url = ReasonReact.Router.useUrl()
    let path = String.concat("/", url.path)
    let isActive = (path ++ ("?" ++ url.search))->Js.String2.endsWith(href)
    <a
      href
      onClick={event =>
        switch (ReactEvent.Mouse.metaKey(event), ReactEvent.Mouse.ctrlKey(event)) {
        | (false, false) =>
          ReactEvent.Mouse.preventDefault(event)
          ReasonReact.Router.push(href)
        | _ => ()
        }}
      style=?{switch (style, activeStyle, isActive) {
      | (Some(style), _, false) => Some(style)
      | (Some(style), None, true) => Some(style)
      | (Some(style), Some(activeStyle), true) => Some(ReactDOM.Style.combine(style, activeStyle))
      | (_, Some(activeStyle), true) => Some(activeStyle)
      | _ => None
      }}>
      {text->React.string}
    </a>
  }
}

module DemoListSidebar = {
  module Styles = {
    let demoName = ReactDOM.Style.make(~fontWeight="500", ())
    let link = ReactDOM.Style.make(
      ~textDecoration="none",
      ~color=Color.blue,
      ~display="block",
      ~padding=`${Gap.xs} ${Gap.md}`,
      ~borderRadius="7px",
      ~fontWeight="500",
      (),
    )
    let activeLink = ReactDOM.Style.make(~backgroundColor=Color.blue, ~color=Color.white, ())
  }

  module MenuItem = {
    @react.component
    let make = (~demoName, ~demoUnitNames) =>
      <div key=demoName>
        <PaddedBox> <span style=Styles.demoName> {demoName->React.string} </span> </PaddedBox>
        <PaddedBox padding=LeftRight>
          {demoUnitNames
          ->Array.map(demoUnitName =>
            <Link
              key=demoUnitName
              style=Styles.link
              activeStyle=Styles.activeLink
              href={"?demo=" ++
              (demoName->Js.Global.encodeURIComponent ++
              ("&unit=" ++ demoUnitName->Js.Global.encodeURIComponent))}
              text=demoUnitName
            />
          )
          ->React.array}
        </PaddedBox>
      </div>
  }

  module SearchInput = {
    module Styles = {
      let clearButton = ReactDOM.Style.make(
        ~position="absolute",
        ~right="7px",
        ~display="flex",
        ~cursor="pointer",
        ~border="none",
        ~padding="0",
        ~backgroundColor=Color.transparent,
        ~top="50%",
        ~transform="translateY(-50%)",
        ~margin="0",
        (),
      )

      let inputWrapper = ReactDOM.Style.make(
        ~position="relative",
        ~display="flex",
        ~alignItems="center",
        ~backgroundColor=Color.midGray,
        ~borderRadius="7px",
        (),
      )

      let input = ReactDOMRe.Style.make(
        ~padding=`${Gap.xs} ${Gap.md}`,
        ~width="100%",
        ~margin="0",
        ~fontFamily="inherit",
        ~fontSize="16px",
        ~border="none",
        ~backgroundColor=Color.transparent,
        ~borderRadius="7px",
        (),
      )
    }

    module ClearButton = {
      let iconClose =
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="18"
          height="18"
          viewBox="0 0 18 18"
          style={ReactDOM.Style.make(~display="block", ())}>
          <path
            fill="gray"
            d="M14.53 4.53l-1.06-1.06L9 7.94 4.53 3.47 3.47 4.53 7.94 9l-4.47 4.47 1.06 1.06L9 10.06l4.47 4.47 1.06-1.06L10.06 9z"
          />
        </svg>

      @react.component
      let make = (~onClear) =>
        <button style=Styles.clearButton onClick={_event => onClear()}> iconClose </button>
    }

    @react.component
    let make = (~value, ~onChange, ~onClear) =>
      <div style=Styles.inputWrapper>
        <input style=Styles.input placeholder="Filter" value onChange />
        {value === "" ? React.null : <ClearButton onClear />}
      </div>
  }

  let rec hasNestedEntityWithSubstring = (entityMap: entityMap, substring) => {
    entityMap
    ->MutableMap.String.toArray
    ->Array.some(((entityName, entity)) => {
      let entityNameHasSubstring =
        entityName->Js.String2.toLowerCase->Js.String2.includes(substring)
      switch entity {
      | Demo(_) => entityNameHasSubstring
      | Category(entityMap) =>
        entityNameHasSubstring || hasNestedEntityWithSubstring(entityMap, substring)
      }
    })
  }

  let rec renderMenu = (~filterValue, ~level=(0, ""), entityMap: entityMap) => {
    let demos = entityMap->MutableMap.String.toArray
    let substring = filterValue->Option.mapWithDefault("", Js.String2.toLowerCase)
    let (level, categoryQuery) = level
    let levelStr = Int.toString(level)

    demos
    ->Belt.Array.map(((entityName, entity)) => {
      let entityNameHasSubstring =
        entityName->Js.String2.toLowerCase->Js.String2.includes(substring)

      switch entity {
      | Demo(_) =>
        if entityNameHasSubstring {
          <Link
            key={entityName}
            style=Styles.link
            activeStyle=Styles.activeLink
            href={"?demo=" ++ entityName->Js.Global.encodeURIComponent ++ categoryQuery}
            text=entityName
          />
        } else {
          React.null
        }
      | Category(entityMap) =>
        if entityNameHasSubstring || hasNestedEntityWithSubstring(entityMap, substring) {
          <PaddedBox key={entityName}>
            <PaddedBox> <strong> {entityName->React.string} </strong> </PaddedBox>
            {renderMenu(
              ~filterValue,
              ~level=(
                level + 1,
                `&category${levelStr}=` ++
                entityName->Js.Global.encodeURIComponent ++
                categoryQuery,
              ),
              entityMap,
            )}
          </PaddedBox>
        } else {
          React.null
        }
      }
    })
    ->React.array
  }

  @react.component
  let make = (~demos: entityMap) => {
    let (filterValue, setFilterValue) = React.useState(() => None)
    <Sidebar fullHeight=true>
      <PaddedBox gap=Md border=Bottom>
        <SearchInput
          value={filterValue->Option.getWithDefault("")}
          onChange={event => {
            let value = (event->ReactEvent.Form.target)["value"]
            setFilterValue(_ => value->Js.String2.trim === "" ? None : Some(value))
          }}
          onClear={() => setFilterValue(_ => None)}
        />
      </PaddedBox>
      <PaddedBox gap=Xxs>
        <Stack>
          {
            let filterValue = filterValue->Option.map(s => s->Js.String2.toLowerCase)
            renderMenu(demos, ~filterValue)
          }
        </Stack>
      </PaddedBox>
    </Sidebar>
  }
}

module DemoUnitSidebar = {
  module Styles = {
    let label = ReactDOM.Style.make(
      ~display="block",
      ~backgroundColor=Color.white,
      ~borderRadius="7px",
      ~boxShadow="0 5px 10px rgba(0, 0, 0, 0.07)",
      (),
    )
    let labelText = ReactDOM.Style.make(~fontSize="16px", ~textAlign="center", ())
    let textInput = ReactDOM.Style.make(
      ~fontSize="16px",
      ~width="100%",
      ~boxSizing="border-box",
      ~backgroundColor=Color.lightGray,
      ~boxShadow="inset 0 0 0 1px rgba(0, 0, 0, 0.1)",
      ~border="none",
      ~padding=Gap.md,
      ~borderRadius="7px",
      (),
    )
    let select =
      ReactDOM.Style.make(
        ~fontSize="16px",
        ~width="100%",
        ~boxSizing="border-box",
        ~backgroundColor=Color.lightGray,
        ~boxShadow="inset 0 0 0 1px rgba(0, 0, 0, 0.1)",
        ~border="none",
        ~padding=Gap.md,
        ~borderRadius="7px",
        ~appearance="none",
        ~paddingRight="30px",
        ~backgroundImage=`url("data:image/svg+xml,%3Csvg width='36' height='36' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='%2342484E' stroke-width='2' d='M12.246 14.847l5.826 5.826 5.827-5.826' fill='none' fill-rule='evenodd' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E")`,
        ~backgroundPosition="center right",
        ~backgroundSize="contain",
        ~backgroundRepeat="no-repeat",
        (),
      )->ReactDOM.Style.unsafeAddProp("WebkitAppearance", "none")
    let checkbox = ReactDOM.Style.make(~fontSize="16px", ~margin="0 auto", ~display="block", ())
  }

  module PropBox = {
    @react.component
    let make = (~propName: string, ~children) => {
      <label style=Styles.label>
        <PaddedBox>
          <Stack> <div style=Styles.labelText> {propName->React.string} </div> children </Stack>
        </PaddedBox>
      </label>
    }
  }

  @react.component
  let make = (
    ~strings: Map.String.t<(Configs.stringConfig, string, option<array<(string, string)>>)>,
    ~ints: Map.String.t<(Configs.numberConfig<int>, int)>,
    ~floats: Map.String.t<(Configs.numberConfig<float>, float)>,
    ~bools: Map.String.t<(Configs.boolConfig, bool)>,
    ~onStringChange,
    ~onIntChange,
    ~onFloatChange,
    ~onBoolChange,
  ) =>
    <PaddedBox gap=Md>
      <Stack>
        {strings
        ->Map.String.toArray
        ->Array.map(((propName, (_config, value, options))) =>
          <PropBox key=propName propName>
            {switch options {
            | None =>
              <input
                type_="text"
                value
                style=Styles.textInput
                onChange={event =>
                  onStringChange(propName, (event->ReactEvent.Form.target)["value"])}
              />
            | Some(options) =>
              <select
                style=Styles.select
                onChange={event => {
                  let value = (event->ReactEvent.Form.target)["value"]
                  onStringChange(propName, value)
                }}>
                {options
                ->Array.map(((key, optionValue)) => {
                  <option key selected={value == optionValue} value={optionValue}>
                    {key->React.string}
                  </option>
                })
                ->React.array}
              </select>
            }}
          </PropBox>
        )
        ->React.array}
        {ints
        ->Map.String.toArray
        ->Array.map(((propName, ({min, max}, value))) =>
          <PropBox key=propName propName>
            <input
              type_="number"
              min=j`$min`
              max=j`$max`
              value=j`$value`
              style=Styles.textInput
              onChange={event =>
                onIntChange(propName, (event->ReactEvent.Form.target)["value"]->int_of_string)}
            />
          </PropBox>
        )
        ->React.array}
        {floats
        ->Map.String.toArray
        ->Array.map(((propName, ({min, max}, value))) =>
          <PropBox key=propName propName>
            <input
              type_="number"
              min=j`$min`
              max=j`$max`
              value=j`$value`
              style=Styles.textInput
              onChange={event =>
                onFloatChange(propName, (event->ReactEvent.Form.target)["value"]->float_of_string)}
            />
          </PropBox>
        )
        ->React.array}
        {bools
        ->Map.String.toArray
        ->Array.map(((propName, (_config, checked))) =>
          <PropBox key=propName propName>
            <input
              type_="checkbox"
              checked
              style=Styles.checkbox
              onChange={event => onBoolChange(propName, (event->ReactEvent.Form.target)["checked"])}
            />
          </PropBox>
        )
        ->React.array}
      </Stack>
    </PaddedBox>
}

module DemoUnit = {
  type state = {
    strings: Map.String.t<(Configs.stringConfig, string, option<array<(string, string)>>)>,
    ints: Map.String.t<(Configs.numberConfig<int>, int)>,
    floats: Map.String.t<(Configs.numberConfig<float>, float)>,
    bools: Map.String.t<(Configs.boolConfig, bool)>,
  }

  type action =
    | SetString(string, string)
    | SetInt(string, int)
    | SetFloat(string, float)
    | SetBool(string, bool)

  module Styles = {
    let container = ReactDOM.Style.make(
      ~flexGrow="1",
      ~display="flex",
      ~alignItems="stretch",
      ~flexDirection="row",
      (),
    )
    let contents =
      ReactDOM.Style.make(
        ~flexGrow="1",
        ~overflowY="auto",
        ~display="flex",
        ~flexDirection="column",
        ~alignItems="center",
        ~justifyContent="center",
        (),
      )->ReactDOM.Style.unsafeAddProp("WebkitOverflowScrolling", "touch")
  }

  let getRightSidebarElement = (): option<Dom.element> =>
    Window.window["parent"]["document"]["getElementById"](. rightSidebarId)->Js.Nullable.toOption

  @react.component
  let make = (~demoUnit: Configs.demoUnitProps => React.element) => {
    let (parentWindowRightSidebarElem, setParentWindowRightSidebarElem) = React.useState(() => None)

    React.useEffect0(() => {
      switch getRightSidebarElement() {
      | Some(elem) => setParentWindowRightSidebarElem(_ => Some(elem))
      | None => ()
      }
      None
    })

    React.useEffect0(() => {
      Window.addMessageListener(event => {
        if Window.window["parent"] === event["source"] {
          let message: string = event["data"]
          switch message->Window.Message.fromStringOpt {
          | Some(RightSidebarDisplayed) =>
            switch getRightSidebarElement() {
            | Some(elem) => setParentWindowRightSidebarElem(_ => Some(elem))
            | None => ()
            }
          | None => Js.Console.error("Unexpected message received")
          }
        }
      })
      None
    })

    let (state, dispatch) = React.useReducer(
      (state, action) =>
        switch action {
        | SetString(name, newValue) => {
            ...state,
            strings: state.strings->Map.String.update(name, value =>
              value->Option.map(((config, _value, options)) => (config, newValue, options))
            ),
          }
        | SetInt(name, newValue) => {
            ...state,
            ints: state.ints->Map.String.update(name, value =>
              value->Option.map(((config, _value)) => (config, newValue))
            ),
          }
        | SetFloat(name, newValue) => {
            ...state,
            floats: state.floats->Map.String.update(name, value =>
              value->Option.map(((config, _value)) => (config, newValue))
            ),
          }
        | SetBool(name, newValue) => {
            ...state,
            bools: state.bools->Map.String.update(name, value =>
              value->Option.map(((config, _value)) => (config, newValue))
            ),
          }
        },
      {
        let strings = ref(Map.String.empty)
        let ints = ref(Map.String.empty)
        let floats = ref(Map.String.empty)
        let bools = ref(Map.String.empty)
        let props: Configs.demoUnitProps = {
          string: (name, ~options=?, config) => {
            strings := strings.contents->Map.String.set(name, (config, config, options))
            config
          },
          int: (name, config) => {
            ints := ints.contents->Map.String.set(name, (config, config.initial))
            config.initial
          },
          float: (name, config) => {
            floats := floats.contents->Map.String.set(name, (config, config.initial))
            config.initial
          },
          bool: (name, config) => {
            bools := bools.contents->Map.String.set(name, (config, config))
            config
          },
        }
        let _ = demoUnit(props)
        {
          strings: strings.contents,
          ints: ints.contents,
          floats: floats.contents,
          bools: bools.contents,
        }
      },
    )
    let props: Configs.demoUnitProps = {
      string: (name, ~options as _=?, _config) => {
        let (_, value, _) = state.strings->Map.String.getExn(name)
        value
      },
      int: (name, _config) => {
        let (_, value) = state.ints->Map.String.getExn(name)
        value
      },
      float: (name, _config) => {
        let (_, value) = state.floats->Map.String.getExn(name)
        value
      },
      bool: (name, _config) => {
        let (_, value) = state.bools->Map.String.getExn(name)
        value
      },
    }
    <div name="DemoUnit" style=Styles.container>
      <div style=Styles.contents> {demoUnit(props)} </div>
      {switch parentWindowRightSidebarElem {
      | None => React.null
      | Some(element) =>
        ReactDOM.createPortal(
          <DemoUnitSidebar
            strings=state.strings
            ints=state.ints
            floats=state.floats
            bools=state.bools
            onStringChange={(name, value) => dispatch(SetString(name, value))}
            onIntChange={(name, value) => dispatch(SetInt(name, value))}
            onFloatChange={(name, value) => dispatch(SetFloat(name, value))}
            onBoolChange={(name, value) => dispatch(SetBool(name, value))}
          />,
          element,
        )
      }}
    </div>
  }
}

module DemoUnitFrame = {
  let container = responsiveMode =>
    ReactDOM.Style.make(
      ~flex="1",
      ~display="flex",
      ~justifyContent="center",
      ~alignItems="center",
      ~backgroundColor={
        switch responsiveMode {
        | Mobile => Color.midGray
        | Desktop => Color.white
        }
      },
      ~height="1px",
      ~overflowY="auto",
      (),
    )

  @react.component
  let make = (~queryString: string, ~responsiveMode, ~onLoad: Js.t<'a> => unit) => {
    <div name="DemoUnitFrame" style={container(responsiveMode)}>
      <iframe
        onLoad={event => {
          let iframe = event->ReactEvent.Synthetic.target
          let window = iframe["contentWindow"]
          onLoad(window)
        }}
        src={`?iframe=true&${queryString}`}
        style={ReactDOM.Style.make(
          ~height={
            switch responsiveMode {
            | Mobile => "667px"
            | Desktop => "100%"
            }
          },
          ~width={
            switch responsiveMode {
            | Mobile => "375px"
            | Desktop => "100%"
            }
          },
          ~border="none",
          (),
        )}
      />
    </div>
  }
}

module App = {
  module Styles = {
    let app = ReactDOM.Style.make(
      ~display="flex",
      ~flexDirection="row",
      ~minHeight="100vh",
      ~alignItems="stretch",
      ~color=Color.darkGray,
      (),
    )
    let main = ReactDOM.Style.make(~flexGrow="1", ~display="flex", ~flexDirection="column", ())
    let empty = ReactDOM.Style.make(
      ~flexGrow="1",
      ~display="flex",
      ~flexDirection="column",
      ~alignItems="center",
      ~justifyContent="center",
      (),
    )
    let emptyText = ReactDOM.Style.make(
      ~fontSize="22px",
      ~color=Color.black40a,
      ~textAlign="center",
      (),
    )
    let right = ReactDOM.Style.make(~display="flex", ~flexDirection="column", ~width="100%", ())
    let demo = ReactDOM.Style.make(
      ~display="flex",
      ~flex="1",
      ~flexDirection="row",
      ~alignItems="stretch",
      (),
    )
    let demoContents = ReactDOM.Style.make(~display="flex", ~flex="1", ~flexDirection="column", ())
  }

  let findDemoUnit = (urlSearchParams, demoName, entityMap: entityMap) => {
    let categoryPath =
      urlSearchParams
      ->URLSearchParams.toArray()
      ->Array.filter(((k, _v)) => k != "demo" && k != "iframe")
      ->Array.copy
      ->Array.sortInPlaceWith(((k1, _), (k2, _)) => String.compare(k1, k2))
      ->Belt.List.fromArray

    let rec find = (categoryPath, entityMap: entityMap) => {
      switch categoryPath {
      | list{} =>
        entityMap
        ->Belt.MutableMap.String.get(demoName)
        ->Option.flatMap(entity =>
          switch entity {
          | Demo(demoUnit) => Some(demoUnit)
          | Category(_) => None
          }
        )
      | list{(_categoryNumber, categoryName), ...categoryPath} =>
        entityMap
        ->Belt.MutableMap.String.get(categoryName)
        ->Option.flatMap(entity =>
          switch entity {
          | Category(entityMap) => find(categoryPath, entityMap)
          | Demo(_) => None
          }
        )
      }
    }

    find(categoryPath, entityMap)
  }

  type route =
    | Unit(URLSearchParams.t, string)
    | Demo(string)
    | Home

  @react.component
  let make = (~demos: entityMap) => {
    let url = ReasonReact.Router.useUrl()
    let urlSearchParams = url.search->URLSearchParams.make
    let route = switch (
      urlSearchParams->URLSearchParams.get("iframe"),
      urlSearchParams->URLSearchParams.get("demo"),
    ) {
    | (Some("true"), Some(demoName)) => Unit(urlSearchParams, demoName)
    | (_, Some(_)) => Demo(url.search)
    | _ => Home
    }

    let (loadedIframeWindow: option<Js.t<'a>>, setLoadedIframeWindow) = React.useState(() => None)

    // Force rerender after switching demo to avoid stale iframe and sidebar children
    let (iframeKey, setIframeKey) = React.useState(() => Js.Date.now()->Belt.Float.toString)
    React.useEffect1(() => {
      setIframeKey(_ => Js.Date.now()->Belt.Float.toString)
      None
    }, [url])

    let (showRightSidebar, toggleShowRightSidebar) = React.useState(() => {
      open ReshowcaseUi__Bindings
      localStorage->LocalStorage.getItem("sidebar")->Option.isSome
    })
    let (responsiveMode, setResponsiveMode) = React.useState(() => Desktop)

    React.useEffect1(() => {
      open ReshowcaseUi__Bindings
      if showRightSidebar {
        localStorage->LocalStorage.setItem("sidebar", "1")
      } else {
        localStorage->LocalStorage.removeItem("sidebar")
      }
      None
    }, [showRightSidebar])

    <div name="App" style=Styles.app>
      {switch route {
      | Unit(urlSearchParams, demoName) => {
          let demoUnit = findDemoUnit(urlSearchParams, demoName, demos)
          <div style=Styles.main>
            {demoUnit
            ->Option.map(demoUnit => <DemoUnit demoUnit />)
            ->Option.getWithDefault("Demo not found"->React.string)}
          </div>
        }
      | Demo(queryString) => <>
          <DemoListSidebar demos />
          <div name="Content" style=Styles.right>
            <TopPanel
              isSidebarHidden={!showRightSidebar}
              responsiveMode
              onRightSidebarToggle={() => {
                toggleShowRightSidebar(_ => !showRightSidebar)
                switch loadedIframeWindow {
                | Some(window) if !showRightSidebar =>
                  Window.postMessage(window, RightSidebarDisplayed)
                | None
                | _ => ()
                }
              }}
              setResponsiveMode
            />
            <div name="Demo" style=Styles.demo>
              <div style=Styles.demoContents>
                <DemoUnitFrame
                  key={"DemoUnitFrame" ++ iframeKey}
                  queryString
                  responsiveMode
                  onLoad={iframeWindow => setLoadedIframeWindow(_ => Some(iframeWindow))}
                />
              </div>
              {showRightSidebar
                ? <Sidebar key={"Sidebar" ++ iframeKey} innerContainerId=rightSidebarId />
                : React.null}
            </div>
          </div>
        </>
      | Home => <>
          <DemoListSidebar demos />
          <div style=Styles.empty>
            <div style=Styles.emptyText> {"Pick a demo"->React.string} </div>
          </div>
        </>
      }}
    </div>
  }
}
