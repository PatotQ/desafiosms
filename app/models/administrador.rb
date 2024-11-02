class Administrador < ApplicationRecord
    has_secure_password
    has_many :productos
    has_many :categorias
end
