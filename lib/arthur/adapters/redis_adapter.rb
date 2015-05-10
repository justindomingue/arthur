require 'redis'
require 'json'

module Arthur

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
    def add_reply(input, reply, extra_incr=0)
      p "Adding reply '" + reply + "' to input '" + input
      # Get previous record for `input` or create a new one
      db_value = self.get(input) || {reply => 0}

      # Increment reply count
      db_value[reply] = db_value[reply].to_i.succ + extra_incr

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
