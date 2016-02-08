Sequel.migration do
  change do
    alter_table :events do
      set_column_type :twitter_id, String
    end
  end
end
