class CreateCategoriasProductosJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :categorias, :productos do |t|
      t.index [:categoria_id, :producto_id] 
      t.index [:producto_id, :categoria_id]
    end
  end
end
