# IDE in Docker

* Images with development and GUI packages for running IDE inside docker
* Script to start IDE in container
* Docker-Compose environment with common services like database, queue, etc.

![diagram](diagram.png)

## Getting started

1. Clone/Download this repo
2. [Choose a tag](https://hub.docker.com/r/01e9/ide/tags) for your programming language
3. Start IDE in Docker

    **Important**: IDE must be in home directory

    `./ide {TAG} {IDE-script}`

    Example

    `./ide js ~/some-dir/webstorm/bin/webstorm.sh`

4. Optional: Copy `docker-compose.override.yml.example` to `docker-compose.override.yml`

   and add whatever services you need for your project.

   **Note**: Service/Database host is container name `ide_{SERVICE}`

## Start IDE with short command

Add in `~/.bash_aliases`:

```sh
alias webstorm="env DOCKER_RUN_OPTS='-p 8080:8080 -p 9000:9000' ~/some-dir/docker-ide/ide js ~/another-dir/webstorm/bin/webstorm.sh"
```

Next time start the IDE with alias command `webstorm`.

## Pass options to `x11docker`

```sh
./ide cpp-gpu ~/some-dir/clion/bin/clion.sh -x11docker "--gpu --alsa"
```

## Services examples for `docker-compose.override.yml`

* **MySQL** ([image](https://hub.docker.com/_/mysql))

    ```yaml
    volumes:
      mysql:

    services:
      mysql:
        container_name: ide_mysql
        image: mysql:8
        environment:
          MYSQL_DATABASE: justdoit
          MYSQL_USER: justdoit
          MYSQL_PASSWORD: justdoit
          MYSQL_ROOT_PASSWORD: justdoit
        volumes:
          - mysql:/var/lib/mysql
    ```

    URL example: `mysql://root:justdoit@ide_mysql:3306/db_name?serverVersion=8`

* **PostgreSQL** ([image](https://hub.docker.com/_/postgres))

    ```yaml
    volumes:
      postgres:

    services:
      postgres:
        container_name: ide_postgres
        image: postgres:9
        volumes:
          - postgres:/var/lib/postgresql/data
        environment:
          POSTGRES_USER: "justdoit"
          POSTGRES_PASSWORD: "justdoit"
          POSTGRES_DB: "justdoit"
    ```

    URL example: `postgresql://justdoit:justdoit@ide_postgres:5432/db_name`

* **Redis** ([image](https://hub.docker.com/_/redis))

    ```yaml
    volumes:
      redis:

    services:
      redis:
        container_name: ide_redis
        image: redis:6-alpine
        command: ["redis-server", "--appendonly", "yes"]
        volumes:
          - redis:/data
    ```

    Host: `ide_redis`

* **RabbitMQ** ([image](https://hub.docker.com/_/rabbitmq))

    ```yaml
    volumes:
      rabbitmq:

    services:
      rabbitmq:
        container_name: ide_rabbitmq
        hostname: ide_rabbitmq
        image: rabbitmq:3
        volumes:
          - rabbitmq:/var/lib/rabbitmq
    ```

    URL example: `amqp://guest:guest@ide_rabbitmq:5672/%2f/messages`

* **Elastic Search** ([image](https://www.docker.elastic.co/r/elasticsearch))

    First you have to [fix the memory limit](https://stackoverflow.com/a/59267523/8766845).

    ```yaml
    volumes:
      elastic:

    services:
      elastic:
        image: docker.elastic.co/elasticsearch/elasticsearch:7.12.0
        container_name: ide_elastic
        environment:
          - node.name=ide_elastic
          - cluster.name=es-docker-cluster
          - cluster.initial_master_nodes=ide_elastic
          - bootstrap.memory_lock=true
          - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
        ulimits:
          memlock:
            soft: -1
            hard: -1
        volumes:
          - elastic:/usr/share/elasticsearch/data
    ```

    URL example: `http://ide_elastic:9200`

* **Kibana (Elastic Search Dashboard)** ([image](https://www.docker.elastic.co/r/kibana))

    ```yaml
    elastic_kibana:
      image: docker.elastic.co/kibana/kibana:7.12.0
      container_name: ide_elastic_kibana
      environment:
        ELASTICSEARCH_URL: http://ide_elastic:9200
        ELASTICSEARCH_HOSTS: http://ide_elastic:9200
      ports:
        - 5601:5601
    ```
