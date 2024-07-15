# Kafka Connect Playground

This repository provides a Docker Compose setup to create a Kafka Connect playground for testing connectors and different scenarios. The setup includes Zookeeper, Kafka Broker, Schema Registry, Kafka Connect, MySQL, phpMyAdmin, and Kafkacat.

## Prerequisites

- Docker
- Docker Compose

## Services

### Zookeeper

Zookeeper is used to manage and coordinate Kafka brokers.

- **Image**: `confluentinc/cp-zookeeper:7.0.1`
- **Ports**: 2181

### Kafka Broker

The Kafka broker handles the storage and retrieval of messages.

- **Image**: `confluentinc/cp-kafka:7.0.1`
- **Ports**: 9092
- **Depends on**: Zookeeper

### Schema Registry

Schema Registry provides a serving layer for your metadata.

- **Image**: `confluentinc/cp-schema-registry:7.0.1`
- **Ports**: 8081
- **Depends on**: Kafka Broker

### Kafka Connect

Kafka Connect is used to stream data between Kafka and other systems.

- **Image**: `confluentinc/cp-kafka-connect-base:7.0.1`
- **Ports**: 8083
- **Depends on**: Kafka Broker, Schema Registry

### MySQL

MySQL is used as a sample database for testing JDBC connectors.

- **Image**: `mysql:9.0.0`
- **Ports**: 3306
- **Environment Variables**:
  - `MYSQL_ROOT_PASSWORD=Admin123`
  - `MYSQL_USER=mysqluser`
  - `MYSQL_PASSWORD=mysqlpw`
- **Volumes**:
  - `${PWD}/mysql/00_setup_db.sql:/docker-entrypoint-initdb.d/00_setup_db.sql`
  - `${PWD}/mysql/init-db.sh:/docker-entrypoint-initdb.d/init-db.sh`

### phpMyAdmin

phpMyAdmin is a web interface for managing MySQL databases.

- **Image**: `phpmyadmin:5.2.1-apache`
- **Ports**: 8080
- **Depends on**: MySQL

### Kafkacat

Kafkacat is a command-line utility for interacting with Kafka.

- **Image**: `edenhill/kcat:1.7.1`
- **Depends on**: Kafka Broker, Schema Registry

## Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>

2. **Start Services**:
   ```bash
   docker compose up or
   docker compose up -d

3. **Access phpMyAdmin**:
- **URL:**  http://localhost:8080
- **Username:** mysqluser
- **Password:** mysqlpw

4. **Access Kafka Connect:**
- **URL: http://localhost:8083

## **Kafka Connectors**

### The following connectors are pre-installed

- **HTTP Source Connector:** confluentinc/kafka-connect-http-source:0.2.0
- **JDBC Connector:** confluentinc/kafka-connect-jdbc:10.7.6

## **Customizing Connectors**
To add more connectors, modify the command section in the kafka-connect service in the docker-compose.yml file.

## Example: Creating a JDBC Sink Connector
To create a JDBC Sink Connector, use the following command:
```bash
curl -i -X PUT -H "Accept:application/json" \
    -H "Content-Type:application/json" http://localhost:8083/connectors/sink-jdbc-mysql-00/config \
    -d '{
          "connector.class"     : "io.confluent.connect.jdbc.JdbcSinkConnector",
          "connection.url"      : "jdbc:mysql://mysql:3306/freetestapi",
          "connection.user"     : "mysqluser",
          "connection.password" : "mysqlpw",
          "topics"              : "freetestapi-books",
          "tasks.max"           : "4",
          "auto.create"         : "true",
          "key.converter"       : "org.apache.kafka.connect.json.JsonConverter",
          "key.converter.schemas.enable": "false",
          "value.converter"     : "org.apache.kafka.connect.json.JsonConverter",
          "value.converter.schemas.enable": "false"
        }'
```

## Cheat sheet for Kafka connect rest APIs

| Command                                                                 | Description                             |
|-------------------------------------------------------------------------|-----------------------------------------|
| `curl /connectors`                                                      | Get list of connectors                  |
| `curl -X POST -H "Content-Type: application/json" /connectors -d 'json'`| Create a connector                      |
| `curl /connectors/[name]`                                               | Get information about a single connector|
| `curl /connectors/[name]/config`                                        | Get config of a single connector        |
| `curl -X PUT -H "Content-Type: application/json" /connectors/[name]/config -d 'json'` | Create or update a connector config     |
| `curl /connectors/[name]/status`                                        | Get the status of a connector           |
| `curl -X POST /connectors/[name]/restart`                               | Restart a connector                     |
| `curl -X PUT /connectors/[name]/pause`                                  | Pause a connector                       |
| `curl -X PUT /connectors/[name]/resume`                                 | Resume a connector                      |
| `curl -X DELETE /connectors/[name]`                                      | Delete a connector                      |
| `curl /connectors/[name]/tasks`                                         | Get list of tasks for a connector       |
| `curl /connectors/[name]/tasks/[number]/status`                         | Get the status of a single task         |
| `curl -X POST /connectors/[name]/tasks/[number]/restart`                | Restart a single task                   |
| `curl /connector-plugins/`                                              | Get list of plugins                     |

## Using kcat examples
[kcat](https://docs.confluent.io/platform/current/tools/kafkacat-usage.html) (formerly kafkacat) is a command-line utility that you can use to test and debug Apache Kafka® deployments. You can use kcat to produce, consume, and list topic and partition information for Kafka.

- list topics
  ```bash
   docker exec kafkacat kcat -b broker:29092 -L | grep topic
   ```

- Consuming messages from a topic
  ```bash
  docker exec kafkacat kcat -b broker:29092 -t freetestapi-books -C -J | jq '.'
  ```

## **Notes**
The Kafka broker is configured to allow large message sizes (up to 200MB).
The MySQL service uses an initialization script to set up the database.
