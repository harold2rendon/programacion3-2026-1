# Sistema Distribuido de Gestión Inmobiliaria — Elixir
**Universidad del Quindío | Programación III | 2026**

## Requisitos
- Elixir >= 1.14
- Erlang/OTP >= 25

## Instalación y ejecución

```bash
# Instalar dependencias
mix deps.get

# Compilar
mix compile

# Ejecutar (modo interactivo)
iex -S mix
# Luego en IEx:
iex> Inmobiliaria.run()

# Correr tests
mix test
```

## Flujo de uso (ejemplo del enunciado)

```
# Carlos se conecta como vendedor
connect carlos 1234 vendedor

# Carlos publica una propiedad
publish_property tipo=casa modalidad=venta ubicacion=Armenia precio=300000000 habitaciones=4 area=180

# Ana se conecta como cliente
connect ana 4321 cliente

# Ana lista propiedades disponibles
list_properties

# Ana envía un mensaje al publicador
send_message prop001 Hola, me interesa esta casa. ¿Sigue disponible?

# Ana compra la propiedad
buy_property prop001

# Ver ranking
ranking
```

## Arquitectura

```
Inmobiliaria.Application (Supervisor principal)
├── Inmobiliaria.UserManager      (GenServer — usuarios y puntajes)
├── Inmobiliaria.PropertyManager  (GenServer — catálogo de propiedades)
├── Inmobiliaria.MessageManager   (GenServer — mensajería)
├── Inmobiliaria.SessionManager   (GenServer — sesiones activas)
└── Inmobiliaria.PropertySupervisor (Supervisor)
    ├── Registry (PropertyRegistry)
    └── DynamicSupervisor
        ├── Property:prop001      (GenServer por propiedad)
        ├── Property:prop002      (GenServer por propiedad)
        └── ...
```

## Archivos de datos

| Archivo | Contenido |
|---|---|
| `data/users.dat` | usuarios, roles, contraseñas, puntajes |
| `data/properties.dat` | propiedades registradas |
| `data/results.log` | historial de compras y arriendos |
| `data/messages.log` | mensajes entre usuarios |
| `data/locations.dat` | ubicaciones válidas |

## Concurrencia

Cada propiedad corre como un **proceso GenServer independiente**. Cuando dos clientes intentan comprar la misma propiedad simultáneamente, el modelo de actores de Erlang garantiza que solo uno lo logre — los mensajes se procesan secuencialmente dentro del proceso de la propiedad.
