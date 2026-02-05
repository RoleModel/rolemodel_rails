import { describe, it, expect } from 'vitest'

describe('Invisible Class', () => {
  it('shows the element', async () => {
    document.body.innerHTML = `
      <button">My Button</button>
    `

    const button = document.querySelector('button')
    await expect.element(button).toBeVisible()
  })
})
