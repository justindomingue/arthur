require 'sequel'

module Arthur
  class DBHelper
    @@DB = Sequel.sqlite

    def self.create_database

      # Create Inputs table
      @@DB.create_table :inputs do
        primary_key :id
        String      :text, text: true, null: false
        index       :text, unique: true
      end

      # Create Replies table
      @@DB.create_table :replies do
        primary_key :id
        foreign_key :input_id, :inputs, on_delete: 'cascade'
        String      :text, text: true, null: false
        Int         :count, default: 1
      end
    end

    # TODO create a view to get all questions ith invalid answers

    def self.get_inputs
      return @@DB[:inputs]
    end

    def self.get_replies
      return @@DB[:replies]
    end
  end
end

