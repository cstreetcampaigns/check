class AddFieldsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :mobile, :string, :default => nil
    add_column :people, :work_phone_number, :string, :default => nil
    add_column :people, :home_zip, :string, :default => nil
  end
end
