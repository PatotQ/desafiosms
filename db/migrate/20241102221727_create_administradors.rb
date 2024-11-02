class CreateAdministradors < ActiveRecord::Migration[7.0]
  def change
    create_table :administradors do |t|
      t.string :nombre
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
