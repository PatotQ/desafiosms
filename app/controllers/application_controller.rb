class ApplicationController < ActionController::Base
  def authenticate_administrador!
    unless request.headers['Authorization'].present?
      render json: { error: 'Token no proporcionado' }, status: :unauthorized
      return
    end

    token = request.headers['Authorization'].split(' ').last
    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.jwt_secret_key, true, algorithm: 'HS256')
      @current_administrador = Administrador.find(decoded_token[0]['administrador_id'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Token inválido o administrador no encontrado' }, status: :unauthorized
    end
  end
end
