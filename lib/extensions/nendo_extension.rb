module NendoExtension
  def nendo
    mon < 4 ? year - 1 : year
  end
end
Time.prepend(NendoExtension)
Date.prepend(NendoExtension)
