class NotificarPrimeraCompraJob
  include Sidekiq::Job

  def perform(compra_id)
    compra = Compra.find(compra_id)
    producto = compra.producto

    if producto.compras.count == 1
      administrador = producto.administrador
      AdministradorMailer.nueva_compra_email(producto, compra.cliente, administrador).deliver_now
    end
  end
end
