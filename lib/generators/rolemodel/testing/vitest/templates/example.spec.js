import { describe, it, expect } from 'vitest'

describe('Invisible Class', () => {
  it('makes the element invisible', async () => {
    document.body.innerHTML = `
      <button class="invisible">My Button</button>
    `

    const button = document.querySelector('button')
    await expect.element(button).not.toBeVisible()
  })
})
