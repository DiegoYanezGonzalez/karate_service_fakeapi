1) login.feature (Autenticación)

```js
Feature: Login en Fake Store API

  @ObtenerToken
  Scenario: Obtener token de acceso
    Given url baseUrl + '/auth/login'
    And request {username: 'mor_2314', password: '83r5^_'}
    When method post
    Then status 201
    And match response == { token: '#string' }
    * def authToken = response.token

```

Qué hace

Llama a POST /auth/login con usuario y password válidos.

Verifica que la respuesta tenga un campo token (string).

Expone authToken para que otros features puedan reutilizarlo con callonce.


2) flujoCarroCompra.feature (Flujo CRUD del carro)
   Background

```js
Background:
  * url baseUrl
  * def login = callonce read('login.feature')
  * def tokenAcceso = login.token ? login.token : login.authToken
  * header Authorization = 'Bearer ' + tokenAcceso
  * match tokenAcceso == '#string'
  * assert tokenAcceso.trim().length > 0

```
Qué hace

Configura la baseUrl desde karate-config.js.

Ejecuta el login una sola vez (callonce) y toma el token (tolera token o authToken).

Inyecta el header Authorization.

Valida que el token sea string y no esté vacío.


Escenario 1: flujo “crear → actualizar → dejar 1 producto → consultar → borrar”

```js
@FlujoCarro
Scenario: Crear, actualizar y dejar un producto en el carro
  # 1) CREATE
  * def cuerpoCrear =
  """
  { "userId": 1, "date": "2020-02-03", "products": [ { "productId": 1, "quantity": 1 } ] }
  """
  Given path 'carts'
  And request cuerpoCrear
  When method POST
  Then status 201
  * def idCarro = response.id

  # 2) GET productos disponibles y guardar 3
  Given path 'products'
  When method GET
  Then status 200
  * def producto1 = response[0]
  * def producto2 = response[1]
  * def producto3 = response[2]

  # 3) PUT: dejar 3 productos en el carro
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
  * def productosCarro1 = response.products ? response.products : []
  * assert productosCarro1.length == 3

  # 4) PUT: dejar solo 1 (el tercero)
  Given path 'carts', idCarro
  And request
  """
  { "userId": 1, "products": [ { "productId": #(producto3.id), "quantity": 1 } ] }
  """
  When method PUT
  Then status 200
  * def productosCarro2 = response.products ? response.products : []
  * assert productosCarro2.length == 1
  * match productosCarro2[0].productId == producto3.id

  # 5) GET final y validaciones
  Given path 'carts', idCarro
  When method GET
  Then status 200
  * def productosFinales = response.products ? response.products : []
  * if (productosFinales.length > 0) karate.assert(productosFinales.length == 1)
  * if (productosFinales.length > 0) karate.assert(productosFinales[0].productId == producto3.id)

  # 6) DELETE (opcional)
  Given path 'carts', idCarro
  When method DELETE
  Then status 200
  * if (response && response.id != null) karate.assert(response.id == idCarro)

```
Qué valida

El POST crea un carro y recupera idCarro.

Con PUT mete 3 productos y luego otro PUT deja solo 1.

Con GET final comprueba que queda 1 producto y que sea el producto3.

El DELETE borra el carro (si la API retorna cuerpo, verifica el id).


3) Escenario Data-Driven (Scenario Outline) con JSON externo

```js
@FlujoCarroDD
Scenario Outline: Carro data-driven - <name>
  # CREATE
  * def bodyCrear =
  """
  { "userId": <userId>, "date": "<date>", "products": <initialProducts> }
  """
  Given path 'carts'
  And request bodyCrear
  When method POST
  Then status 201
  * def idCarro = response.id

  # PUT con 3 productos
  Given path 'carts', idCarro
  And request
  """
  { "userId": <userId>, "products": <threeProducts> }
  """
  When method PUT
  Then status 200
  * def prods3 = response.products ? response.products : []
  * assert prods3.length == 3

  # PUT para dejar 1 producto
  Given path 'carts', idCarro
  And request
  """
  { "userId": <userId>, "products": [ { "productId": <keepProductId>, "quantity": 1 } ] }
  """
  When method PUT
  Then status 200
  * def prods1 = response.products ? response.products : []
  * assert prods1.length == 1
  * match prods1[0].productId == <keepProductId>

  # GET final y DELETE
  Given path 'carts', idCarro
  When method GET
  Then status 200
  * def finalProds = response.products ? response.products : []
  * if (finalProds.length > 0) karate.assert(finalProds.length == 1)
  * if (finalProds.length > 0) karate.assert(finalProds[0].productId == <keepProductId>)

  Given path 'carts', idCarro
  When method DELETE
  Then status 200
  * if (response && response.id != null) karate.assert(response.id == idCarro)

Examples:
  | read('classpath:json/carts-dd.json') |

```
Cómo funciona

Usa Scenario Outline para parametrizar: <name>, <userId>, <date>, <initialProducts>, <threeProducts>, <keepProductId>.

Las filas vienen del archivo json/carts-dd.json. Ejemplo de estructura mínima por fila:

```js
{
  "name": "Caso 1",
  "userId": 1,
  "date": "2020-02-03",
  "initialProducts": [ { "productId": 1, "quantity": 1 } ],
  "threeProducts": [
    { "productId": 1, "quantity": 1 },
    { "productId": 2, "quantity": 1 },
    { "productId": 3, "quantity": 1 }
  ],
  "keepProductId": 3
}

```