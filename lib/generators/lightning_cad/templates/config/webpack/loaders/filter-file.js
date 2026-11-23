/**
 * Webpack loader to filter server-only or client-only sections of code out of
 * a file, based on the current target (e.g., 'web' or 'node')
 */
export default function (source, target = this.target) {
  let begin, end
  if (target === 'web') {
    begin = '// @begin-server-only'
    end = '// @end-server-only'
  } else {
    begin = '// @begin-client-only'
    end = '// @end-client-only'
  }

  let filteredSource = source
  let beginIndex = filteredSource.indexOf(begin)
  let endIndex = filteredSource.indexOf(end)
  while (beginIndex !== -1) {
    const afterExcludedBlock = endIndex === -1 ? '' : filteredSource.slice(endIndex + end.length)
    filteredSource = filteredSource.slice(0, beginIndex) + afterExcludedBlock
    beginIndex = filteredSource.indexOf(begin)
    endIndex = filteredSource.indexOf(end)
  }

  return filteredSource
}
