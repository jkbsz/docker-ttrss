# Old repo - does not work anymore

# TTRSS Docker Compose

## Description

A way to run Tiny Tiny RSS (https://tt-rss.org/) in a docker container.

Two containers:
- DB: PostgreSQL
- App: Apache + PHP + TT-RSS

PostgreSQL data is stored inside a Docker Volume to persist data batween restarts and upgrades.
Still I would not update before backing up the Volume.
By design needs something in front that will provide encryption.

## Usage

docker-compose up --detach


login on http://127.0.0.1/
user: admin
password: password


