function fn() {
  var env = karate.env || 'qa';

  // Default base
  var config = { env: env, baseUrl: 'https://fakestoreapi.com' };

  if (env == 'qa') {
    config.baseUrl = 'https://fakestoreapi.com';
  } else if (env == 'prod') {
    config.baseUrl = 'https://fakestoreapi.com';
  }

  // Short, safe timeouts to prevent “hang”
  karate.configure('connectTimeout', 3000);
  karate.configure('readTimeout', 5000);

  // Optional: force HTTP logging to see what happens
  // karate.configure('logPrettyRequest', true);
  // karate.configure('logPrettyResponse', true);

  return config;
}
