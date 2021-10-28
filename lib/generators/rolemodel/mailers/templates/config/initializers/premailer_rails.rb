module CustomPropertyCSSHelper
  def load_css(url)
    # strip out any CSS Custom Properties, PostCSS includes the fallbacks,
    # but Premailer can't ignore them so we remove them
    super.gsub(/(\b[a-z_-]*?:[^\n;{}]*var\(.*?)?\B--.*?(;|(?=\}))/, '')
  end
end

class Premailer
  module Rails
    module CSSHelper
      extend CustomPropertyCSSHelper
    end
  end
end
