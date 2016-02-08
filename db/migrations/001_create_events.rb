Sequel.migration do
  change do
    create_table :ferries do
      primary_key :id
      String :name, null: false, unique: true
    end

    create_table :events do
      primary_key :id
      foreign_key :ferry_id, :ferries, null: false
      Integer :twitter_id, index: true, null: false, unique: true
      String :message, null: false
      String :reason, null: false
      Time :created_at, null: false, index: true, unique: true

      String :event_type, null: false
      index [:id, :event_type]
    end
  end
end
