# dockerhub-php7.0.33-fpm
Configured PHP 7.0.33-fpm for CI 2

To compile:

> docker login
> docker build -t yohannaftali/php7.0.33-fpm .
> docker tag yohannaftali/php7.0.33-fpm:latest yohannaftali/php7.0.33-fpm
> docker push yohannaftali/php7.0.33-fpm:latest