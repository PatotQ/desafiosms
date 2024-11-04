require "rails_helper"

RSpec.describe ProductosController, type: :controller do
  let!(:administrador) { Administrador.create!(nombre: "Admin", email: "admin@example.com", password: "password") }
  let!(:categoria) { Categoria.create!(nombre: "Electrónica", administrador: administrador) }
  let!(:producto) { Producto.create!(nombre: "Smartphone", precio: 699.99, categorias: [categoria], administrador: administrador) }
  let!(:cliente) { Cliente.create!(nombre: "Juan Pérez", email: "juan@example.com") }
  let!(:compra) { Compra.create!(producto: producto, cliente: cliente, cantidad: 2, created_at: '2023-06-15 10:00:00') }
  let!(:compra2) { Compra.create!(producto: producto, cliente: cliente, cantidad: 3, created_at: '2023-06-15 11:00:00') }

  before do
    secret_key = Rails.application.credentials.jwt_secret_key
    token = JWT.encode({ administrador_id: administrador.id }, secret_key, 'HS256')
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe "GET #index" do
    it "devuelve una lista de productos" do
      get :index, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(Producto.count)
      json_response.each do |producto|
        expect(producto).to include('id', 'nombre', 'precio')
      end
    end
  end

  describe "GET #show" do
    it "devuelve un producto específico" do
      get :show, params: { id: producto.id }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(producto.id)
      expect(json_response['nombre']).to eq(producto.nombre)
      expect(json_response['precio'].to_s).to eq(producto.precio.to_s)
    end
  end

  describe "GET #productos_mas_comprados" do
    it "devuelve los productos más comprados por categoría" do
      get :productos_mas_comprados, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response).not_to be_empty
      json_response.each do |categoria|
        expect(categoria).to include('categoria', 'productos')
        expect(categoria['productos']).to be_an(Array)
        categoria['productos'].each do |producto|
          expect(producto).to include('id', 'nombre', 'total_compras')
        end
      end
    end
  end

  describe "GET #productos_mas_recaudados" do
    it "devuelve los productos con mayor recaudación por categoría" do
      get :productos_mas_recaudados, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response).not_to be_empty
      json_response.each do |categoria|
        expect(categoria).to include('categoria', 'productos')
        expect(categoria['productos']).to be_an(Array)
        categoria['productos'].each do |producto|
          expect(producto).to include('id', 'nombre', 'total_recaudado')
        end
      end
    end
  end

  describe "GET #buscar_compras" do
    it "devuelve las compras filtradas por fecha" do
      compra
      get :buscar_compras, params: { fecha_desde: '2023-01-01', fecha_hasta: '2023-12-31' }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      compra_response = json_response.first
      expect(compra_response['id']).to eq(compra.id)
      expect(compra_response['cantidad']).to eq(compra.cantidad)
      expect(compra_response['cliente']['id']).to eq(cliente.id)
      expect(compra_response['cliente']['nombre']).to eq(cliente.nombre)
      expect(compra_response['producto']['id']).to eq(producto.id)
      expect(compra_response['producto']['nombre']).to eq(producto.nombre)
      expect(compra_response['producto']['precio'].to_s).to eq(producto.precio.to_s)
      expect(compra_response['total']).to eq((compra.cantidad * producto.precio).to_s)
    end

  end

  describe "GET #compras_por_granularidad" do
    before { compra }

    it "devuelve compras agrupadas por día" do
      get :compras_por_granularidad, params: { granularidad: 'dia', fecha_desde: '2023-01-01', fecha_hasta: '2023-12-31' }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_a(Hash)
      date_key = compra.created_at.strftime("%Y-%m-%d")
      expect(json_response[date_key]).to eq(compra.cantidad + compra2.cantidad)
    end

    it "devuelve compras agrupadas por hora" do
      get :compras_por_granularidad, params: { granularidad: 'hora', fecha_desde: '2023-01-01', fecha_hasta: '2023-12-31' }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_a(Hash)
      time_key = compra.created_at.strftime("%Y-%m-%d %H:00:00 UTC")
      expect(json_response[time_key]).to eq(compra.cantidad)
    end

    it "devuelve compras agrupadas por semana" do
      get :compras_por_granularidad, params: { granularidad: 'semana', fecha_desde: '2023-01-01', fecha_hasta: '2023-12-31' }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_a(Hash)
      expect(json_response['2023-06-11']).to eq(compra.cantidad + compra2.cantidad)
    end

    it "devuelve compras agrupadas por año" do
      get :compras_por_granularidad, params: { granularidad: 'año', fecha_desde: '2023-01-01', fecha_hasta: '2023-12-31' }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_a(Hash)
      expect(json_response['2023-01-01']).to eq(compra.cantidad + compra2.cantidad)
    end
  end

  context "sin autenticación" do
    before do
      request.headers['Authorization'] = nil
    end

    it "no permite acceder al índice" do
      get :index, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end