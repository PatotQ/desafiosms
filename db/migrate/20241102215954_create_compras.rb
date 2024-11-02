class CreateCompras < ActiveRecord::Migration[7.0]
  def change
    create_table :compras do |t|
      t.integer :cliente_id
      t.integer :producto_id
      t.integer :cantidad

      t.timestamps
    end
  end
end
