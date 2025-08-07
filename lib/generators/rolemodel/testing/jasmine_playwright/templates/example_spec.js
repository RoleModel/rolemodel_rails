import { html } from '@rolemodel/jasmine-playwright-runner/dom'
import { page } from '@rolemodel/jasmine-playwright-runner/page'

describe('example', () => {
  it('is there', async () => {
    const content = 'Hello World'
    await html`
    <div>
      ${content}
    </div>
    `

    await expectAsync(page.getByText(content)).toBeInTheDocument()
  })
})
