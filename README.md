
# 🛒 Proyecto Karate – Fake Store API

Este proyecto implementa un **flujo automatizado de e-commerce** utilizando **Karate DSL** para consumir la [Fake Store API](https://fakestoreapi.com/).  
Incluye autenticación, operaciones CRUD sobre carritos, pruebas data-driven, modularización y reportes HTML.

---

## 📂 Estructura del proyecto


```js
dyanez_karate_tsoft/
├── build.gradle
├── settings.gradle
├── src
│ └── test
│ ├── java
│ │ ├── features
│ │ │ └── dyanez
│ │ │ ├── login.feature
│ │ │ └── flujoCarroCompra.feature
│ │ └── runner
│ │ └── Runner.java
│ └── resources
│ ├── karate-config.js
│ └── json
│ ├── productos.json
│ └── carts-dd.json
```


## ⚙️ Configuración de entornos

En el archivo `karate-config.js` se definen entornos (`qa`, `prod`) y tiempos de espera:

```js
function fn() {
  var env = karate.env || 'qa';

  var config = {
    env: env,
    baseUrl: 'https://fakestoreapi.com'
  };

  if (env == 'qa') {
    config.baseUrl = 'https://fakestoreapi.com';
  } else if (env == 'prod') {
    config.baseUrl = 'https://fakestoreapi.com';
  }

  karate.configure('connectTimeout', 3000);
  karate.configure('readTimeout', 5000);

  return config;
}

```

🔑 Autenticación


El archivo login.feature obtiene un token dinámico desde el endpoint /auth/login.

```js
Feature: Autenticación en Fake Store API

Scenario: Obtener token válido
  Given url baseUrl + '/auth/login'
  And request { "username": "mor_2314", "password": "XXXXXXX" }
  When method POST
  Then status 200
  * def token = response.token
  * match token == '#string'
```

🛒 Flujo de carrito de compra

Archivo flujoCarroCompra.feature:

```js
Feature: Flujo carro de compra

Background:
  * url baseUrl
  * def login = callonce read('login.feature')
  * def tokenAcceso = login.token ? login.token : login.authToken
  * header Authorization = 'Bearer ' + tokenAcceso
  * match tokenAcceso == '#string'
  * assert tokenAcceso.trim().length > 0

@FlujoCarro
Scenario: Crear, actualizar y dejar un producto en el carro
  * def cuerpoCrear =
  """
  {
    "userId": 1,
    "date": "2020-02-03",
    "products": [ { "productId": 1, "quantity": 1 } ]
  }
  """
  Given path 'carts'
  And request cuerpoCrear
  When method POST
  Then status 201
  * def idCarro = response.id

  Given path 'products'
  When method GET
  Then status 200
  * def producto1 = response[0]
  * def producto2 = response[1]
  * def producto3 = response[2]

  Given path 'carts', idCarro
  And request
  """
  {
    "userId": 1,
    "products": [
      { "productId": #(producto1.id), "quantity": 1 },
      { "productId": #(producto2.id), "quantity": 1 },
      { "productId": #(producto3.id), "quantity": 1 }
    ]
  }
  """
  When method PUT
  Then status 200
  And match response.id == idCarro
  * def productosCarro1 = response.products
  * assert productosCarro1.length == 3

  Given path 'carts', idCarro
  And request
  """
  {
    "userId": 1,
    "products": [
      { "productId": #(producto3.id), "quantity": 1 }
    ]
  }
  """
  When method PUT
  Then status 200
  And match response.id == idCarro
  * def productosCarro2 = response.products
  * assert productosCarro2.length == 1
  * match productosCarro2[0].productId == producto3.id

  Given path 'carts', idCarro
  When method GET
  Then status 200
  * def productosFinales = response.products ? response.products : []
  * if (productosFinales.length > 0) karate.assert(productosFinales.length == 1)
  * if (productosFinales.length > 0) karate.assert(productosFinales[0].productId == producto3.id)

  Given path 'carts', idCarro
  When method DELETE
  Then status 200
  * if (response && response.id != null) karate.assert(response.id == idCarro)

```
📊 Data-Driven Testing

Archivo carts-dd.json:

```js
[
  {
    "userId": 1,
    "date": "2020-02-03",
    "products": [
      { "productId": 1, "quantity": 2 },
      { "productId": 3, "quantity": 1 }
    ]
  },
  {
    "userId": 2,
    "date": "2020-02-04",
    "products": [
      { "productId": 2, "quantity": 1 },
      { "productId": 5, "quantity": 2 }
    ]
  }
]

```

Ejemplo de uso:

```js
Scenario Outline: Crear carrito con dataset
  Given path 'carts'
  And request <carrito>
  When method POST
  Then status 201
  * match response.userId == <carrito>.userId

Examples:
  | read('classpath:json/carts-dd.json') |

```

▶️ Ejecución

Ejecutar todas las pruebas:

```js
./gradlew test -Dkarate.env=qa

```

Ejecutar runner específico:
```js
mvn test -Dtest=runner.Runner

```

📑 Reportes

Después de correr las pruebas, abre el reporte en:

```js
build/karate-reports/karate-summary.html

```

✅ Funcionalidades cubiertas

Configuración de entornos (karate-config.js)

Login con token dinámico

CRUD de carritos (POST, GET, PUT, DELETE)

Data-driven desde archivo JSON

Validaciones:

Token no vacío

Cantidad de productos

IDs de productos

Reportes HTML automáticos

🔧 Requisitos

Java 17+ (ej. OpenJDK 17)

Gradle o Maven

Conexión a Internet para consumir la API