require 'answerific'

module Arthur
  class PrinceOfWales

    attr_reader :db, :dont_know_phrases

    # Initialize Arthur, Prince Of Wales
    #
    # Opts:
    #   db: database used to store the information
    #   prev: initial previous reply
    #
    def initialize(opts={})
      @db = opts[:db] || Arthur::RedisAdapter.new
      @prev_reply = opts[:prev] || ""
      @dont_know_phrases = opts[:dont_know_phrases] || ["Huh...", "I don't know..."]

      # Untrained inputs created in the current session
      @session_untrained_inputs= Set.new

      @answerific = Answerific::Miner.new
    end

    # Replies to `input`
    #
    # Example: reply('how do you feel?') #=> Good, thanks
    #
    # Return: String
    #
    def reply(input)
      input = input.remove_new_lines.remove_non_alpha_numeric
      reply = ""

      # Arthur said `@prev_reply` and user replied with `input`
      p "prev reply is " + @prev_reply.to_s
      @db.add_reply(@prev_reply, input) if @prev_reply

      # Get the *valid* replies for the input from the database
      replies = @db.get_valid_answers_for(input)

      # If replies nil      -> input not found
      # If replies count 0  -> no validated answers
      # Otherwise           -> valid answers
      if replies
        if replies.count > 0
          reply = replies.sample
          @prev_reply = reply.dup
        else
          reply = "No validated answers yet."
          @prev_reply = nil
        end
      else
        # At this point, Arthur doesn't know how to reply to `input`
        # If the input looks like a question, use Answerific to mine the web for an answer
        # Otherwise, reply with one of the untrained inputs

        is_question = input.start_with? "wh" or input.start_with? "how"

        if is_question && !input.include?("you")
          # Using Answerific, get an answer
          reply = @answerific.answer input

          # Don't save the reply
          @prev_reply = nil

          # Tell the user that this answer was searched for
          reply.prepend "Here's what I found for you. "
        else
          # Get untrained inputs so Arthur can learn how to reply to them
          reply = @db.get_untrained_inputs.sample.to_s.sub(@db.untrained_key_prefix, '')

          # Keep track of previous reply: either an untrained input or nothing (only help msg)
          @prev_reply = reply.empty? ? nil : reply.dup

          # Prepend a help message to the reply
          reply.prepend @dont_know_phrases.sample + ' '

          # Track the untrained input
          untrained_key = @db.untrained_key_for(input)
          @db.set(untrained_key, [])
          @session_untrained_inputs << untrained_key
        end
      end

      return reply
    end

    alias :r :reply

    # Trains Arthur::PrinceOfWales  with a basic corpus of questions/answers
    def learn_proper_etiquette
      @db.train_from_file

      p "Arthur::PrinceOfWales is now ready to converse."
    end
  end
end
