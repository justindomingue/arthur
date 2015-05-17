require 'spec_helper'

describe Arthur::RedisAdapter do
  before(:each) do
    # Use fakeredis
    @redis = Redis.new
    @redis_adapter = Arthur::RedisAdapter.new(@redis)
  end

  it '.get' do
    @redis.set "b", "[1,2,3]" # array

    expect(@redis_adapter.get("nothing")).to be_nil
    expect(@redis_adapter.get("b")).to eq [1,2,3]
  end

  it '.set' do
    @redis_adapter.set "b", [1,2,3]

    expect(@redis.get "b").to eq "[1,2,3]"
  end

  context '.add_reply' do
    before(:each) do
      @redis_adapter.add_reply('input', 'reply')
    end

    it 'creates a new reply with count 1' do
      db_value = @redis_adapter.get('input')
      expect(db_value['reply']).to eq 1
    end

    it '.increments an existing reply' do
      @redis_adapter.add_reply('input', 'reply')
      db_value = @redis_adapter.get('input')
      expect(db_value['reply']).to eq 2
    end

    it '.creates a new reply with specific count' do
      @redis_adapter.add_reply('input2', 'reply', Arthur::REPLY_COUNT_TRESHOLD)
      db_value = @redis_adapter.get('input2')
      expect(db_value['reply']).to eq Arthur::REPLY_COUNT_TRESHOLD+1
    end

    it '.removes untrained input record' do
      @redis_adapter.set('_untrained', '{}')
      expect(@redis_adapter.redis.exists('_untrained')).to be true

      @redis_adapter.add_reply('untrained', 'reply')
      expect(@redis_adapter.redis.exists('_untrained')).to be false
    end
  end

  context '.get_valid_answers_for' do
    it 'returns nil when input not in db' do
      expect(@redis_adapter.get_valid_answers_for('xxx')).to be_nil
    end

    it 'returns an empty array when no input reach treshhold count' do
      pending('treshold too low - case will never happen') if Arthur::REPLY_COUNT_TRESHOLD <= 1
      @redis_adapter.add_reply('input', 'reply')
      expect(@redis_adapter.get_valid_answers_for('input')).to eq []
    end

    it 'returns an array with valid answers' do
      pending('threshold too low for this test') if Arthur::REPLY_COUNT_TRESHOLD < 3

      @redis_adapter.add_reply('input', 'reply1')
      @redis_adapter.add_reply('input', 'reply1')
      @redis_adapter.add_reply('input', 'reply1')

      @redis_adapter.add_reply('input', 'reply2')
      @redis_adapter.add_reply('input', 'reply2')
      @redis_adapter.add_reply('input', 'reply2')

      @redis_adapter.add_reply('input', 'reply3')
      @redis_adapter.add_reply('input', 'reply3')

      expect(@redis_adapter.get_valid_answers_for('input')).to eq ['reply1', 'reply2']
    end
  end

  context '.train' do
    it do
      data = {
        "a"=>["a1", "a2", "a3"],
        "b"=>["b1"]
      }

      @redis_adapter.train(data)

      expect(@redis_adapter.get('a').keys).to eq ['a1', 'a2', 'a3']
      expect(@redis_adapter.get('a').values).to eq Array.new(3) {Arthur::REPLY_COUNT_TRESHOLD+1}

      expect(@redis_adapter.get('b').keys).to eq ['b1']
      expect(@redis_adapter.get('b').values).to eq Array.new(1) {Arthur::REPLY_COUNT_TRESHOLD+1}
    end
  end
end
