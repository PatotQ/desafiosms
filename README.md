# Desafio SMS

## Requisitos

- Ruby >= 3.0 (tuve problemas en descargar la version 1.9.3 requerida)

## Instalación

1. **Instalar dependencias:**
    ```bash
    bundle install
    ```

2. **Configurar credenciales:**
    ```bash
    EDITOR="vim" bin/rails credentials:edit
    ```
    Agregar:
    ```yaml
    jwt_secret_key: clave_secreta_de_prueba
    ```

3. **Configurar la base de datos:**
    ```bash
    rails db:create
    rails db:migrate
    rails db:seed
    ```

4. **Iniciar el servidor:**
    ```bash
    rails s
    ```
