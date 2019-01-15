docker kill leemblog;
docker rm $(docker ps -a -q);
docker rmi $(docker images -q -f dangling=true);
docker rmi leemblog;
sh start.sh;
