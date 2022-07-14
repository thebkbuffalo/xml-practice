class AddFilerAndReceiverBooleansToOrganization < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :is_filer, :boolean, default: false
    add_column :organizations, :is_receiver, :boolean, default: false
  end
end
