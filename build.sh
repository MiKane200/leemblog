sed -i "s/localhost/$(docker-machine ip $(docker-machine active))/" config.toml;
docker build -t leemblog:1.0.0 .