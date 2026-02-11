
SRCS_DIR = srcs/
DOCKER_COMPOSE = $(SRCS_DIR)docker-compose.yml

DATA_DIR = /home/trpham/data
MARIADB_DIR = $(DATA_DIR)/mariadb
WORDPRESS_DIR = $(DATA_DIR)/wordpress

all:  mariadb_data wordpress_data build up 

mariadb_data:
	@echo "Create Mariadb data directory"
	@mkdir -p $(MARIADB_DIR)

wordpress_data:
	@echo "Create Wordpress data directory"
	@mkdir -p $(WORDPRESS_DIR)

# looking for -f file .yml in the srcs dir
build:
	sudo chmod -R 775 $(DATA_DIR)
	docker compose -f $(DOCKER_COMPOSE) build

up:
	docker compose -f $(DOCKER_COMPOSE) up -d

down:
	docker compose -f $(DOCKER_COMPOSE) down

clean: down

fclean: clean
	@echo "Remove data directory !!"
	@sudo rm -rf $(DATA_DIR)
#remove all unused volumn in system
	@docker system prune -f --volumes 

re: fclean all

.PHONY: all clean fclean re build up down mariadb_data wordpress_data



 