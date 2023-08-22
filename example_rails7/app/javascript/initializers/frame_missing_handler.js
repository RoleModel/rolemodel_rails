// Correctly handle redirects after modal form submission.
// Required in Turbo 7.3.0 (turbo-rails 1.4.0) and above.
// See https://github.com/hotwired/turbo/pull/863 for details.
document.addEventListener("turbo:frame-missing", (event) => {
  if (event.target.id === "modal" || event.target.id === "panel") {
    event.preventDefault()
    event.detail.visit(event.detail.response.url)
  }
})
