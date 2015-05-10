require "json"
require "arthur/version"
require "arthur/string"
require "arthur/adapters/redis_adapter"

module Arthur

  REPLY_COUNT_TRESHOLD = 3

  class PrinceOfWales

    attr_accessor :db

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

      # Arthur said `@prev_reply` and user replied with `input`
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
        # TODO - Create record with no replies so arthur can ask other people
        reply = "I don't know... but I'll be sure to ask around!"
        @prev_reply = nil
      end

      reply
    end

    def go_train()
      @db.train_from_file
    end
  end
end
