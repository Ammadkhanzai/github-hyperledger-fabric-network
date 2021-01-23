docker rm -f $(docker ps -a -q)
sleep 3
docker volume rm $(docker volume ls -q)