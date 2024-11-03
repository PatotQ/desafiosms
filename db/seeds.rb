# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# db/seeds.rb

Compra.delete_all
Producto.delete_all
Categoria.delete_all
Cliente.delete_all
Administrador.delete_all

administradores = Administrador.create!([
  { nombre: 'Admin1', email: 'admin1@example.com', password: 'password1' },
  { nombre: 'Admin2', email: 'admin2@example.com', password: 'password2' }
])

clientes = Cliente.create!([
  { nombre: 'Cliente1', email: 'cliente1@example.com' },
  { nombre: 'Cliente2', email: 'cliente2@example.com' },
  { nombre: 'Cliente3', email: 'cliente3@example.com' }
])

categorias = Categoria.create!([
  { nombre: 'Electrónica' },
  { nombre: 'Ropa' },
  { nombre: 'Hogar' }
])

productos = Producto.create!([
  { nombre: 'Smartphone', precio: 299.99, categoria: [categorias[0]], administrador: administradores[0] },
  { nombre: 'Laptop', precio: 799.99, categoria: [categorias[0]], administrador: administradores[1] },
  { nombre: 'Camisa', precio: 29.99, categoria: [categorias[1]], administrador: administradores[0] },
  { nombre: 'Sofá', precio: 499.99, categoria: [categorias[2]], administrador: administradores[1] }
])

Compra.create!([
  { producto: productos[0], cliente: clientes[0], cantidad: 2 },
  { producto: productos[1], cliente: clientes[1], cantidad: 1 },
  { producto: productos[2], cliente: clientes[2], cantidad: 3 },
  { producto: productos[3], cliente: clientes[0], cantidad: 1 },
  { producto: productos[0], cliente: clientes[2], cantidad: 1 },
  { producto: productos[3], cliente: clientes[1], cantidad: 2 }
])

puts "Seeds creados exitosamente."