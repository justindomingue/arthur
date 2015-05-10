require "json"
require "arthur/version"
require "arthur/string"
require "arthur/adapters/redis_adapter"

module Arthur
  class Bot

    def initialize
      @db = Arthur::RedisAdapter.new

      training = {
        'hello' => {'hey there' => 3, 'hi' => 5},
        'how are you' => {'i\'m good, thanks' => 1},
        'where are you' => {'wherever you are, that\'s where i am' => 3, 'here and there...' => 3}
      }

      training.each_pair do |k,v|
        v.each_pair do |r,c|
          c.times do
            @db.add_reply(k, r)
          end
        end
      end
    end

    # TODO @prev_bot_reply should be initialized with 'greeting' record

    # Replies to `input`
    #
    # Example: reply('how do you feel?') #=> Good, thanks
    #
    # Return: String
    #
    def reply(input)
      p "Replying to " + input

      input = input.remove_new_lines.remove_non_alpha_numeric
      reply = ""

      @prev_input = input

      # Bot said `@prev_reply` and user replied with `input`
      @db.add_reply(@prev_reply, input) if @prev_reply

      # Get the input from the database
      replies = @db.get_valid_answers_for(input)

      if replies
        if replies.count > 0
          reply = replies.sample
          @prev_reply = reply
        else
          reply = replies.count > 0 ? replies.sample : "No validated answers yet."
          @prev_reply = nil
        end
      else
        reply = "I don't know... but I'll be sure to ask around!"
        @prev_reply = nil
      end

      reply
    end

    # Trains the bot with data in file at `filename`
    def train_from_file(filename='data/training_set.json')
      file = File.read(filename)
      data = JSON.parse(file)
      self.train(data)
    end

    # Trains the bot with the ruby object in `data`
    # Expected format:
    #   { 'input1': ['reply1', 'reply2', ...],
    #     ...
    #     'inputK': "input1"     <== reference
    #   }
    def train(data)
      data.each_pair do |k,v|
        if v.is_a? String
          # TODO alias
        else
          v.each { |reply| @db.add_reply(k, reply, Arthur::REPLY_COUNT_TRESHOLD) }
        end
      end
    end
  end
end
