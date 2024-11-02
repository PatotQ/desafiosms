class AdministradorMailer < ActionMailer::Base
    default from: 'notificaciones@desafiosms.com'

    def nueva_compra_email(producto, comprador, administrador)
        @producto = producto
        @comprador = comprador
        @administrador = administrador
        @otros_administradores = Administrador.where.not(id: administrador.id)

        mail(
        to: administrador.email,
        cc: @otros_administradores.pluck(:email),
        subject: "Primera compra del producto #{@producto.nombre}"
        )
    end

    def reporte_compras_diario_email(administrador, reporte)
        @administrador = administrador
        @reporte = reporte

        mail(
            to: administrador.email,
            subject: "Reporte de Compras del Día Anterior"
        )
    end
end
