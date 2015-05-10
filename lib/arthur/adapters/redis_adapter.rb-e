require 'redis'
require 'json'

module Arthur

  # TODO put back to 3
  REPLY_COUNT_TRESHOLD = 1

  # A database adapter that uses Redis to store the information
  # Format:
  #   input => {"reply1": count1, "reply2", count2, ...}
  #
  class RedisAdapter

    def initialize(redis=Redis.new)
      @redis = redis
    end

    # Gets value for `key`
    #
    def get(key)
      value = @redis.get(key)

      return nil if value.nil? || value.empty?

      JSON.parse(value)
    end

    # Sets `key` to value `object`
    # Params:
    #   key: String
    #   object: Object
    #
    def set(key, object)
      @redis.set(key, object.to_json)
    end

    # Adds `reply` to key `input` in the database
    def add_reply(input, reply, count=0)
      p "Adding reply '" + reply + "' to input '" + input
      # Get previous record for `input` or create a new one
      db_value = self.get(input) || {reply => count}

      # Increment reply count
      db_value[reply] = db_value[reply].to_i.succ

      # Save to database
      self.set(input, db_value)
    end

    # Returns
    #   An array of valid answers in reply to `input`
    #   nil if `input` has no record in the database
    #   []  if `input` has no replies with count higher than REPLY_COUNT_TREHSHOLD
    #
    #   TODO order answers by count
    #
    def get_valid_answers_for(input)
      db_value = get(input)
      !db_value ?
        nil :
        db_value.select { |_, v| v >= Arthur::REPLY_COUNT_TRESHOLD }.keys
    end
  end
end
