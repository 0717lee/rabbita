///|
priv enum GuardRoute {
  Home
  Docs(String, fragment~ : String)
} derive(Eq)

///|
impl @common.Enumerate for GuardRoute with fn tag(self) {
  match self {
    Home => "home"
    Docs(_, ..) => "docs:core"
  }
}

///|
test "switch disposes outgoing branch before evaluating its projections" {
  let (route, set_route) = @duplix.input(
    GuardRoute::Docs("array", fragment="a"),
  )
  let route = Val(route)
  let page = route.switch(current => {
    match current {
      Home => Val::constant("home")
      Docs(_, ..) => {
        let current_path = route.map(route => {
          guard! route is Docs(path, ..)
          path
        })
        let fragment = route.map(route => {
          guard! route is Docs(_, fragment~)
          fragment
        })
        current_path.map2(fragment, (path, fragment) => path + "#" + fragment)
      }
    }
  })
  inspect(page.0.read(), content="array#a")
  set_route(Docs("string", fragment="b"))
  inspect(page.0.read(), content="string#b")
  set_route(Home)
  inspect(page.0.read(), content="home")
}
