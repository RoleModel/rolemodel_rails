global.matchMedia = function(_queryString) {
  const mockMediaQueryList = {
    matches: false,
    addListener: () => {},
    removeListener: () => {},
    addEventListener: () => {},
    removeEventListener: () => {}
  }

  return mockMediaQueryList
}

window.matchMedia = global.matchMedia
