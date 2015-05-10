require 'spec_helper'

describe Arthur::PrinceOfWales do
  context '.train' do
    let(:bot) { Arthur::PrinceOfWales.new }

    it do
      data = {
        "a"=>["a1", "a2", "a3"],
        "b"=>["b1"]
      }

      bot.train(data)

    end
  end
end
