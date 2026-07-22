import { Controller } from '@hotwired/stimulus'
import { patch } from '@rails/request.js'

export default class extends Controller {
  static values = { url: String, count: Number }

  async perform({ params: { url: urlParam, query: queryParams } }) {
    const body = new FormData(this.element)

    if (queryParams) Object.keys(queryParams).forEach(key => body.append(key, queryParams[key]))

    const response = await patch(urlParam || this.urlValue, { body, responseKind: 'turbo-stream' })
    if (response.ok) this.countValue += 1
  }
}
