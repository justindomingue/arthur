require 'spec_helper'

describe Arthur::PrinceOfWales do
  it '.reply' do
    # Simulate a conversation
    # -> hello
    # . hi
    # -> I don't know...
    # . where is Pluto?
    # -> I don't know... hi
    # . hey
    # -> I don't know... Where is Pluto?
    # . In the sky!
    arthur = Arthur::PrinceOfWales.new prev: 'hello', redis: Redis.new, dont_know_phrases: ["Huh"]

    expect(arthur.reply('hi')).to eq 'Huh '
    expect(arthur.reply('where is pluto')).to eq 'Huh hi'
    expect(arthur.reply('hey')).to eq 'Huh where is pluto'
    expect(arthur.reply('in the sky')).to eq 'Huh '
  end
end
