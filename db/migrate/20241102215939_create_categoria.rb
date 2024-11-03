class CreateCategoria < ActiveRecord::Migration[7.0]
  def change
    create_table :categorias do |t|
      t.string :nombre
      t.references :administrador, foreign_key: true
      t.timestamps
    end
  end
end
