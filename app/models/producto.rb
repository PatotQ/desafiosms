class Producto < ApplicationRecord
    has_and_belongs_to_many :categorias
    has_many :compras
    has_many :clientes, through: :compras
    has_many :imagenes
end
