Feature: Login en Fake Store API

  @ObtenerToken
  Scenario: Obtener token de acceso
    Given url baseUrl + '/auth/login'
    And request {username: 'mor_2314', password: '83r5^_'}
    When method post
    Then status 201
    And match response == { token: '#string' }
     * def authToken = response.token
