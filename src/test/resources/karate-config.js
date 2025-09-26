function fn() {
  var env = karate.env || 'qa';

  var config = { env: env, baseUrl: 'https://fakestoreapi.com' };

  if (env == 'qa') {
    config.baseUrl = 'https://fakestoreapi.com';
  } else if (env == 'prod') {
    config.baseUrl = 'https://fakestoreapi.com';
  }

  karate.configure('connectTimeout', 3000);
  karate.configure('readTimeout', 5000);

  return config;
}
