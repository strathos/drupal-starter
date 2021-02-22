# Drupal starter
## Prerequisites
- docker
- docker-compose
- git
- make
## Getting started
Start by creating a project directory and cloning this starter into it:
```bash
mkdir project-name && cd $_
git clone https://github.com/strathos/drupal-starter.git .
rm -rf .git
```
Create project files with the following command:
```bash
make init
```
Now you should have a `.env` file in your project directory. Edit it to match your environment, at least the following:
```bash
PROJECT_NAME=starter
PROJECT_BASE_URL=starter.local.test
PROJECT_PORT=8000
```
You may also change the DB settings, but in a development environment those shouldn't matter that much.

At this point you don't have yet a hash salt, so leave that as dummy value for now.

Then install Drupal with the following command:
```bash
make drupal
```
You need to continue the installation in your web browser. Install script should print out the url where to connect.

The values are not pre-populated, so fill them with the same information you have in your `.env` file. NOTE! To change database hostname from localhost to something else, you need to click on the "Show advanced" option.

After the installation is done, check the created hash salt:
```bash
grep SITE_HASH_SALT src/web/sites/default/settings.php
```
Put this value to your `.env` file. Then copy the generic `settings.php` file over the generated one:
```bash
chmod +w src/web/sites/default/settings.php
cp utils/settings.php src/web/sites/default/settings.php
```
This settings file doesn't include anything that couldn't go to a public Git repository.

Now also copy a pre-configured `.gitignore` file to the src directory:
```bash
cp utils/web.gitignore src/.gitignore
```
## Basic usage
Start the containers:
```bash
make up
```
Check status of the containers:
```bash
make ps
```
Stop and remove the container:
```bash
make down
```
Run Composer commands:
```bash
make composer -- --args command
```
Run Drush commands:
```bash
make drush -- --args command
```
Open a shell to the application container:
```bash
make shell
```
Pull images:
```bash
make pull
```
