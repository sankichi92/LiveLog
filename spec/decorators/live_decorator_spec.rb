require 'rails_helper'

describe LiveDecorator do
  let(:live) { Live.new.extend LiveDecorator }
  subject { live }
  it { should be_a Live }
end
