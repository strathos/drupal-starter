include .env

default: up

COMPOSER_ROOT ?= /var/www/html
DRUPAL_ROOT ?= /var/www/html/web

## help	:	Print commands help.
.PHONY: help
ifneq (,$(wildcard docker.mk))
help : docker.mk
	@sed -n 's/^##//p' $<
else
help : Makefile
	@sed -n 's/^##//p' $<
endif

## up	:	Start up containers.
.PHONY: up
up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	@docker-compose up -d --remove-orphans --build

## down	:	Delete containers.
down:
	@echo "Stopping and deleting containers for $(PROJECT_NAME)..."
	@docker-compose down

## start	:	Start containers without updating.
.PHONY: start
start:
	@echo "Starting containers for $(PROJECT_NAME) from where you left off..."
	@docker-compose start

## stop	:	Stop containers.
.PHONY: stop
stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

## prune	:	Remove containers and their volumes.
##		You can optionally pass an argument with the service name to prune single container
##		prune mariadb	: Prune `mariadb` container and remove its volumes.
##		prune mariadb solr	: Prune `mariadb` and `solr` containers and remove their volumes.
.PHONY: prune
prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v $(filter-out $@,$(MAKECMDGOALS))

## ps	:	List running containers.
.PHONY: ps
ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

## shell	:	Access `php` container via shell.
.PHONY: shell
shell:
	@docker exec -u www-data -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_app' --format "{{ .ID }}") sh

## composer	:	Executes `composer` command in a specified `COMPOSER_ROOT` directory (default is `/var/www/html`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make composer "update drupal/core --with-dependencies"
.PHONY: composer
composer:
	@docker exec -u www-data $(PROJECT_NAME)_app composer --working-dir=$(COMPOSER_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## init	:	Initialize the project files.
.PHONY: init
init:
	@mkdir db-init || true
	@mkdir src || true
	@cp utils/example.env .env || true
	@echo "Project files initialized"

## drupal	:	Install Drupal.
.PHONY: drupal
drupal:
	@echo "Starting the containers and installing Drupal..."
	@docker-compose pull || true
	@docker-compose up -d --remove-orphans --build
	@sleep 1
	@docker exec -u www-data $(PROJECT_NAME)_app composer --working-dir=$(COMPOSER_ROOT) $(filter-out $@,$(MAKECMDGOALS)) create-project drupal/recommended-project .
	@echo
	@echo "Drupal installed with Composer. Go to: http://$(PROJECT_BASE_URL):$(PROJECT_PORT) to continue"

## pull	:	Pull images.
.PHONY: pull
pull:
	@echo "Pulling images..."
	@docker-compose pull || true

## drush	:	Executes `drush` command in a specified `DRUPAL_ROOT` directory (default is `/var/www/html/web`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make drush "watchdog:show --type=cron"
.PHONY: drush
drush:
	@docker exec -u www-data $(PROJECT_NAME)_app drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## logs	:	View containers logs.
##		You can optinally pass an argument with the service name to limit logs
##		logs php	: View `php` container logs.
##		logs nginx php	: View `nginx` and `php` containers logs.
.PHONY: logs
logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

## addwrite	:	Add write permission to relevant files.
.PHONY: addwrite
addwrite:
	@chmod +w src/web/sites/default/settings.php && chmod +w src/web/sites/default

## removewrite	:	Remove write permission from relevant files.
.PHONY: removewrite
removewrite:
	@chmod -w src/web/sites/default/settings.php && chmod -w src/web/sites/default

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
