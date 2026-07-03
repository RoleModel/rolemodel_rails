module CustomPropertyCSSHelper
  def load_css(url)
    # strip out any CSS Custom Property declarations, since Premailer can't
    # inline them. Any var() references should specify a literal fallback
    # value (e.g. var(--op-color-primary, #005) ) so styles survive inlining.
    super.gsub(/((\b[a-z_-]*?:)?[^\n;{}]*var\(.*?)?\B--.*?(,(?=\n)|;(?!\S)|(?=\}))/, '')
  end
end

class Premailer
  module Rails
    module CSSHelper
      extend CustomPropertyCSSHelper
    end
  end
end
