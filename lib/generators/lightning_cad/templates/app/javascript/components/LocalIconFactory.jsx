import React from 'react'
import classnames from 'classnames'

import { IconFactory } from '@rolemodel/lightning-cad-ui'

import MaterialIcon from './MaterialIcon.jsx'

const customIcons = {}

export default class LocalIconFactory extends IconFactory {
  constructor(props) {
    super(props);

    this._iconNameAlias = {
      KeyboardArrowLeft: "keyboard_arrow_left",
      KeyboardArrowRight: "keyboard_arrow_right",
      KeyboardArrowDown: "keyboard_arrow_down",
      ArrowBack: "keyboard_backspace",
      Lock: "lock",
      LockOpen: "lock_open",
      Visibility: "visibility",
      VisibilityOff: "visibility_off",
      undo: "arrow_back",
      redo: "arrow_forward",
    };
  }

  makeIcon(name, otherProps) {
    const iconName = this._iconNameAlias[name] || name;

    const iconProps = {
      className: otherProps.className,
      title: otherProps.hoverText || otherProps.name,
    };

    if (iconName in customIcons) {
      return this._customIcon(iconName, iconProps);
    }

    return <MaterialIcon iconName={iconName} iconProps={iconProps} />;
  }

  /* eslint-disable react/no-danger */
  _customIcon(iconName, { className, ...otherProps }) {
    // Setting innerHTML is not dangerous with these SVG files since we created
    // them and they are part of this app's code.
    return (
      <span
        className={classnames("custom-icons", className)}
        {...otherProps}
        dangerouslySetInnerHTML={{ __html: customIcons[iconName] }}
      />
    );
  }
  /* eslint-enable react/no-danger */
}
