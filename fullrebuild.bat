docker-compose rm --stop --force
docker system prune -f 
docker rmi $(docker images -q)
docker volume prune -f
docker network prune -f
docker-compose build
docker-compose up -d