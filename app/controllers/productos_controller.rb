class ProductosController < ApplicationController
  def index
      @productos = Producto.all
      render json: @productos
    end
  
    def show
      @producto = Producto.find(params[:id])
      render json: @producto
    end
end
