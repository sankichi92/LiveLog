module I18nHelper
  def t(key, options = {})
    I18n.translate(key, options)
  end
end
