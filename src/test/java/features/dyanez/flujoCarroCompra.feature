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
    * def productosCarro1 = response.products ? response.products : []
    * assert productosCarro1.length == 3

    Given path 'carts', idCarro
    And request
  """
  {
    "userId": 1,
    "products": [ { "productId": #(producto3.id), "quantity": 1 } ]
  }
  """
    When method PUT
    Then status 200
    * def productosCarro2 = response.products ? response.products : []
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

  @FlujoCarroDD
  Scenario Outline: Carro data-driven - <name>
    * def bodyCrear =
  """
  {
    "userId": <userId>,
    "date": "<date>",
    "products": <initialProducts>
  }
  """
    Given path 'carts'
    And request bodyCrear
    When method POST
    Then status 201
    * def idCarro = response.id

    Given path 'carts', idCarro
    And request
  """
  {
    "userId": <userId>,
    "products": <threeProducts>
  }
  """
    When method PUT
    Then status 200
    * def prods3 = response.products ? response.products : []
    * assert prods3.length == 3

    Given path 'carts', idCarro
    And request
  """
  {
    "userId": <userId>,
    "products": [ { "productId": <keepProductId>, "quantity": 1 } ]
  }
  """
    When method PUT
    Then status 200
    * def prods1 = response.products ? response.products : []
    * assert prods1.length == 1
    * match prods1[0].productId == <keepProductId>

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
