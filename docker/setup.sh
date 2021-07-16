#!/bin/bash

prepare_config()
{
  FABMANAGER_PATH=${1:-/apps/fabmanager}

  mkdir -p "$FABMANAGER_PATH/example"
  mkdir -p "$FABMANAGER_PATH/elasticsearch/config"

  # fab-manager environment variables
  cat anovmanager/docker/env.example > "$FABMANAGER_PATH/example/env.example"

  # nginx configuration
  cat anovmanager/docker/nginx_with_ssl.conf.example > "$FABMANAGER_PATH/example/nginx_with_ssl.conf.example"
  cat anovmanager/docker/nginx.conf.example > "$FABMANAGER_PATH/example/nginx.conf.example"

  # let's encrypt configuration
  cat anovmanager/docker/webroot.ini.example > "$FABMANAGER_PATH/example/webroot.ini.example"

  # ElasticSearch configuration files
  cat anovmanager/docker/elasticsearch.yml > "$FABMANAGER_PATH/elasticsearch/config/elasticsearch.yml"
  cat anovmanager/docker/log4j2.properties > "$FABMANAGER_PATH/elasticsearch/config/log4j2.properties"

  # docker-compose
  cat anovmanager/docker/docker-compose.yml > "$FABMANAGER_PATH/docker-compose.yml"
}

prepare_config "$@"
