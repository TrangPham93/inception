
SRCS_DIR = srcs/
DOCKER_COMPOSE = $(SRCS_DIR)docker-compose.yml

all: build up

# looking for -f file .yml in the srcs dir
build:
	docker compose -f $(DOCKER_COMPOSE) build --no-cache

up:
	docker compose -f $(DOCKER_COMPOSE) up -d

down:
	docker compose -f $(DOCKER_COMPOSE) down

ps:
	docker compose -f $(DOCKER_COMPOSE) ps

clean: down

fclean: clean
	@echo "No more file to remove !!"

re: fclean all

.PHONY: all clean fclean re



 