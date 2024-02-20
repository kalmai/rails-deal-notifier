class AddUserRelationshipToContactMethods < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :contact_methods, :user, index: { algorithm: :concurrently }
  end
end
