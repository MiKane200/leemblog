sed -i "s/localhost/$(docker-machine ip $(docker-machine active))/" config.toml;
docker build -t leemblog .
docker run --name=leemblog -d -p 1313:1313 leemblog:1.0.0