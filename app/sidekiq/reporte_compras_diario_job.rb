class ReporteComprasDiarioJob
  include Sidekiq::Job

  def perform
    compras_de_ayer = Compra.where(created_at: Date.yesterday.all_day)

    reporte = compras_de_ayer.group_by(&:producto).map do |producto, compras|
      {
        producto: producto.nombre,
        cantidad_total: compras.sum(&:cantidad),
        detalles_compras: compras.map do |compra|
          {
            cliente: compra.cliente.nombre,
            cantidad: compra.cantidad,
            fecha: compra.created_at
          }
        end
      }
    end

    Administrador.all.each do |admin|
      AdministradorMailer.reporte_compras_diario_email(admin, reporte).deliver_now
    end
  end
end
