import React from 'react'

// To display React components in your view, import them into the react_controller.js Stimulus
// controller and then use the react_component view helper to mount them in your Rails view:
//
// = react_component 'HelloReact', currentTime: Time.now

export default function HelloReact({ currentTime }) {
  return (
    <div>
      Hello! The current time is {currentTime}
    </div>
  )
}
