# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_11_02_221727) do
  create_table "administradors", force: :cascade do |t|
    t.string "nombre"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorias", force: :cascade do |t|
    t.string "nombre"
    t.integer "administrador_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrador_id"], name: "index_categorias_on_administrador_id"
  end

  create_table "categorias_productos", id: false, force: :cascade do |t|
    t.integer "categoria_id", null: false
    t.integer "producto_id", null: false
    t.index ["categoria_id", "producto_id"], name: "index_categorias_productos_on_categoria_id_and_producto_id"
    t.index ["producto_id", "categoria_id"], name: "index_categorias_productos_on_producto_id_and_categoria_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.string "nombre"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "compras", force: :cascade do |t|
    t.integer "cliente_id"
    t.integer "producto_id"
    t.integer "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imagens", force: :cascade do |t|
    t.string "url"
    t.integer "producto_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "productos", force: :cascade do |t|
    t.string "nombre"
    t.text "descripcion"
    t.decimal "precio"
    t.integer "administrador_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrador_id"], name: "index_productos_on_administrador_id"
  end

  add_foreign_key "categorias", "administradors"
  add_foreign_key "productos", "administradors"
end
