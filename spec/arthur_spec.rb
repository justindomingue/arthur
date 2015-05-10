require 'spec_helper'

describe Arthur::Bot do
  context '.train' do
    let(:bot) { Arthur::Bot.new }

    it do
      data = {
        "a"=>["a1", "a2", "a3"],
        "b"=>["b1"]
      }

      bot.train(data)

    end
  end
end
