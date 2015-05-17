require 'redis'
require 'json'

module Arthur

  # A database adapter that uses Redis to store the information
  # Format:
  #   input => {"reply1": count1, "reply2", count2, ...}
  #
  class RedisAdapter

    attr_accessor :redis

    NO_VALID_KEY_PREFIX = '_'
    NO_VALID_VALUE      = {}

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
    #   object: Object or nil if input `key` has no replies
    #
    def set(key, object)
      object = Arthur::RedisAdapter::NO_VALID_VALUE if object.nil?

      @redis.set(key, object.to_json)
    end

    # Returns the untrained key for `key`
    def untrained_key_for(key)
      NO_VALID_KEY_PREFIX + key
    end

    def untrained_key_prefix
      NO_VALID_KEY_PREFIX
    end

    # Adds `reply` to key `input` in the database
    # Takes care of removing untrained input as well
    def add_reply(input, reply, extra_incr=0)

      p "Adding reply '" + reply + "' to input '" + input

      # Remove untrained input record if it exists
      @redis.del(untrained_key_for(input))

      # Get previous record for `input` or create a new one
      db_value = self.get(input) || {reply => 0}

      # Increment reply count
      db_value[reply] = db_value[reply].to_i.succ + extra_incr

      # Save to database
      self.set(input, db_value)
    end

    # Gets a valid answer for input `input`
    #
    # Returns:
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

    # Returns an array of inputs without valid answers
    def get_untrained_inputs()
      @redis.scan_each(match: '_*').to_a
    end

    # Trains the bot with data in file at `filename`
    def train_from_file(filename='../../data/training_set.json')
      file = File.read(File.expand_path(filename, __FILE__))
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
          v.each { |reply| self.add_reply(k, reply, Arthur::REPLY_COUNT_TRESHOLD) }
        end
      end
    end
  end
end
