import React from 'react'
import classnames from 'classnames'
import * as PropTypes from 'prop-types'

function MaterialIcon({ iconName, iconProps: { className, ...otherProps } }) {
  return (
    <span
      className={classnames('material-symbols-outlined', className)}
      {...otherProps}
    >
      {iconName}
    </span>
  )
}

MaterialIcon.propTypes = {
  iconName: PropTypes.string,
  iconProps: PropTypes.shape({
    className: PropTypes.string,
    title: PropTypes.string,
    hoverText: PropTypes.string,
    name: PropTypes.string
  })
}

export default MaterialIcon
