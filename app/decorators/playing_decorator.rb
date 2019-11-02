module PlayingDecorator
  def inst_dot
    "#{inst}." if inst.present?
  end

  def handle_with_inst
    "#{inst_dot}#{user.handle}"
  end
end
