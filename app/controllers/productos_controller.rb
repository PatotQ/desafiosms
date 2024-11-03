class ProductosController < ApplicationController
  before_action :authenticate_administrador!

  def index
    @productos = Rails.cache.fetch("productos/all", expires_in: 1.hour) do
      Producto.all
    end
    render json: @productos
  end

  def show
    @producto = Rails.cache.fetch("productos/#{params[:id]}", expires_in: 1.hour) do
      Producto.find(params[:id])
    end
    render json: @producto
  end

  def productos_mas_comprados
    @productos_por_categoria = Rails.cache.fetch("productos_mas_comprados", expires_in: 1.hour) do
      Categoria.includes(:productos)
               .all
               .map do |categoria|
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
    end

    render json: @productos_por_categoria
  end

  def productos_mas_recaudados
    @productos_por_categoria = Rails.cache.fetch("productos_mas_recaudados", expires_in: 1.hour) do
      Categoria.includes(:productos)
               .all
               .map do |categoria|
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
    end

    render json: @productos_por_categoria
  end

  def buscar_compras
    cache_key = "buscar_compras/#{buscar_compras_params.to_json}"
    
    resultado = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
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

      compras.includes(:producto, :cliente).map do |compra|
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
    end

    render json: resultado
  end

  def compras_por_granularidad
    cache_key = "compras_por_granularidad/#{buscar_compras_params.to_json}"
    
    resultado_formateado = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      compras = Compra.joins(:producto)
      
      if buscar_compras_params[:fecha_desde].present? && buscar_compras_params[:fecha_hasta].present?
        fecha_desde = DateTime.parse(buscar_compras_params[:fecha_desde])
        fecha_hasta = DateTime.parse(buscar_compras_params[:fecha_hasta])
        compras = compras.where(created_at: fecha_desde..fecha_hasta)
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

      resultado = case buscar_compras_params[:granularidad]
      when 'hora'
        compras.group_by_hour(:created_at).sum(:cantidad)
      when 'dia'
        compras.group_by_day(:created_at).sum(:cantidad)
      when 'semana'
        compras.group_by_week(:created_at, format: '%Y-%m-%d').sum(:cantidad)
      when 'año'
        compras.group_by_year(:created_at).sum(:cantidad)
      else
        compras.group_by_day(:created_at).sum(:cantidad)
      end

      resultado.transform_keys(&:to_s)
    end

    render json: resultado_formateado
  end

  private

  def buscar_compras_params
    params.permit(:fecha_desde, :fecha_hasta, :categoria_id, :cliente_id, :administrador_id, :granularidad)
  end
end
