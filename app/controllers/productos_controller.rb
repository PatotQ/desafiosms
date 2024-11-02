class ProductosController < ApplicationController
  def index
    @productos = Producto.all
    render json: @productos
  end

  def show
    @producto = Producto.find(params[:id])
    render json: @producto
  end

  def productos_mas_comprados
    @productos_por_categoria = Categoria.all.map do |categoria|
      productos = categoria.productos
                          .joins(:compras)
                          .select('productos.*, SUM(compras.cantidad) as total_compras')
                          .group('productos.id')
                          .order('total_compras DESC')
                          .limit(5)

      {
        categoria: categoria.nombre,
        productos: productos.as_json(methods: :total_compras)
      }
    end

    render json: @productos_por_categoria
  end

  def productos_mas_recaudados
    @productos_por_categoria = Categoria.all.map do |categoria|
      productos = categoria.productos
                          .joins(:compras)
                          .select('productos.*, SUM(compras.cantidad * productos.precio) as total_recaudado')
                          .group('productos.id')
                          .order('total_recaudado DESC')
                          .limit(3)

      {
        categoria: categoria.nombre,
        productos: productos.as_json(methods: :total_recaudado)
      }
    end

    render json: @productos_por_categoria
  end

  def buscar_compras
    compras = Compra.joins(:producto)
    
    if buscar_compras_params[:fecha_desde].present? && buscar_compras_params[:fecha_hasta].present?
      fecha_desde = Date.parse(buscar_compras_params[:fecha_desde])
      fecha_hasta = Date.parse(buscar_compras_params[:fecha_hasta])
      compras = compras.where(created_at: fecha_desde.beginning_of_day..fecha_hasta.end_of_day)
    end

    if buscar_compras_params[:categoria_id].present?
      compras = compras.joins(producto: :categoria).where(categorias: { id: buscar_compras_params[:categoria_id] })
    end

    if buscar_compras_params[:cliente_id].present?
      compras = compras.where(cliente_id: buscar_compras_params[:cliente_id])
    end

    if buscar_compras_params[:administrador_id].present?
      compras = compras.joins(producto: :administrador).where(productos: { administrador_id: buscar_compras_params[:administrador_id] })
    end

    resultado = compras.includes(:producto, :cliente).map do |compra|
      {
        id: compra.id,
        fecha: compra.created_at,
        cantidad: compra.cantidad,
        producto: {
          id: compra.producto.id,
          nombre: compra.producto.nombre,
          precio: compra.producto.precio
        },
        cliente: {
          id: compra.cliente.id,
          nombre: compra.cliente.nombre
        },
        total: compra.cantidad * compra.producto.precio
      }
    end

    render json: resultado
  end

  private

  def buscar_compras_params
    params.permit(:fecha_desde, :fecha_hasta, :categoria_id, :cliente_id, :administrador_id)
  end
end
