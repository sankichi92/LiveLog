require 'rails_helper'

describe SongDecorator do
  let(:song) { Song.new.extend SongDecorator }
  subject { song }
  it { should be_a Song }
end
