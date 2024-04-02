// Correctly handle redirects after modal form submission.
// Required in Turbo 7.3.0 (turbo-rails 1.4.0) and above.
// See https://github.com/hotwired/turbo/pull/863 for details.

document.addEventListener('turbo:frame-missing', (event) => {
  if (event.target.id === 'modal' || event.target.id === 'panel') {
    event.preventDefault()
    /**
     * These visit options cause Turbo8 to treat this _breakout_ visit as a
     * _form-submission redirect_ from the underlying page, on which the modal was opened.
     *
     * If that path matches the destination path AND the application is configured for it, then Turbo8
     * will preserve scroll position and MORPH in changes.  Otherwise, this will be a normal TurboDrive visit.
     */
    event.detail.visit(event.detail.response.url, {action: 'replace', referrer: location.href})
  }
})
