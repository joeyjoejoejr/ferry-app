Sequel.migration do
  change do
    alter_table(:events) do
      set_column_allow_null :reason
    end
  end
end
