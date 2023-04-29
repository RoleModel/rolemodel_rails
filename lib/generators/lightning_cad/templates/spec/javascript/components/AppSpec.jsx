import React from "react"
import { render } from "@testing-library/react"
import App from "components/App.jsx"

describe("App", () => {
  it("renders without crashing", () => {
    expect(() => render(<App />)).not.toThrow()
  })
})
