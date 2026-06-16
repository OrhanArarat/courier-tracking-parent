# Courier Tracking System

The Courier Tracking System is a Spring Boot application using microservices architecture, designed for scalability and
high performance.

## 📋 Project Overview

The Courier Tracking System is a distributed system for managing couriers, warehouses, and orders. Each service operates
under its own responsibility and communicates asynchronously via a message queue.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway Port 8080                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Courier    │  │   Distance   │  │   Location   │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  │  (Port 8083) │  │ (Port 8085)  │  │ (Port 8081)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                 │                  │              │
│  ┌──────────────┐                                          │
│  │    Store     │                                          │
│  │   Service    │                                          │
│  │ (Port 8082)  │                                          │
│  └──────────────┘                                          │
│         │                 │                  │              │
└─────────────────────────────────────────────────────────────┘
         │                 │                  │
┌────────┴─────────────────┴──────────────────┴─────────────┐
│              Kafka (Port 9092)                             │
│            Zookeeper (Port 2181)                           │
│            Kafka UI (Port 9090)                            │
└────────────────────────────────────────────────────────────┘
         │                 │                  │
┌────────┴────────┬────────┴────────┬────────┴──────────┐
│                 │                 │                  │
│  PostgreSQL     │  Couchbase      │  MongoDB         │
│  (Port 5432)    │  (Port 8091)    │  (Port 27017)    │
│                 │                 │  Mongo Express   │
│                 │                 │  (Port 7071)     │
└─────────────────┴─────────────────┴──────────────────┘
```

## 🛠️ Technology Stack

| Component    | Version  | Purpose               |
|--------------|----------|-----------------------|
| Java         | 21       | Programming language  |
| Spring Boot  | 3.2.3    | Framework             |
| Spring Cloud | 2023.0.0 | Microservices         |
| PostgreSQL   | 16       | Relational database   |
| Couchbase    | 7.6.1    | NoSQL database        |
| MongoDB      | 5.0      | Document database     |
| Kafka        | 7.6.0    | Message queue         |
| Docker       | -        | Containerization      |
| Maven        | 3.x      | Dependency management |

## 📦 Services

### 1. API Gateway

- **Port:** 8080
- **Description:** Entry point for all requests. Provides routing, load balancing, and authentication.
- **Technology:** Spring Cloud Gateway

### 2. Courier Service

- **Port:** 8083
- **Description:** Management and processing of courier information
- **Database:** PostgreSQL
- **Technology:** Spring Data JPA, Liquibase

### 3. Distance Service

- **Port:** 8085
- **Description:** Distance calculation and optimization algorithms
- **Database:** MongoDB + Couchbase
- **Technology:** Spring Data MongoDB

### 4. Location Service

- **Port:** 8081
- **Description:** Location-based services
- **Database:** MongoDB
- **Technology:** Spring Boot Web

### 5. Store Service

- **Port:** 8082
- **Description:** Management of warehouse/store information
- **Database:** MongoDB + Couchbase
- **Technology:** Spring Boot Web

## 🚀 Getting Started

### Prerequisites

- Java 21 must be installed
- Maven 3.8.0 or higher
- Docker & Docker Compose
- Git

### Installation Steps

1. **Start the infrastructure:**

```bash
cd courier-tracking-parent
docker-compose up -d
```

Docker Compose will start the following services:

- PostgreSQL
- Couchbase
- MongoDB
- Kafka & Zookeeper
- Kafka UI
- Mongo Express

2. **Build the project:**

```bash
cd courier-tracking-parent
mvn clean install
```

3. **Start the services (separate terminal for each):**

**API Gateway:**

```bash
cd api-gateway-courier-tracking
mvn spring-boot:run
```

**Courier Service:**

```bash
cd courier-service
mvn spring-boot:run
```

**Distance Service:**

```bash
cd distance-service
mvn spring-boot:run
```

**Location Service:**

```bash
cd location-service
mvn spring-boot:run
```

**Store Service:**

```bash
cd store-service
mvn spring-boot:run
```

## 🔌 Database Connection Details

| Database   | Host      | Port      | Username | Password   |
|------------|-----------|-----------|----------|------------|
| PostgreSQL | localhost | 5432      | courier  | courier123 |
| MongoDB    | localhost | 27017     | -        | -          |
| Couchbase  | localhost | 8091-8097 | admin    | password   |
| Kafka      | localhost | 9092      | -        | -          |

### Database Interfaces

- **Kafka UI:** http://localhost:9090
- **Mongo Express:** http://localhost:7071
- **Couchbase:** http://localhost:8091

## 📡 API Gateway

All API requests are made through the API Gateway:

```
curl -X GET http://localhost:8080/api/v1/couriers
curl -X GET http://localhost:8080/api/v1/distances
curl -X GET http://localhost:8080/api/v1/locations
curl -X GET http://localhost:8080/api/v1/stores
```

## 🧪 Tests

To run all tests:

```bash
cd courier-tracking-parent
mvn test
```

To test a specific service:

```bash
cd courier-service
mvn test
```

## 🐳 Deployment with Docker

A Dockerfile is available for each service. To run all services with Docker:

```bash
cd courier-tracking-parent
docker-compose -f docker-compose.yml up -d
```

## 📊 Local Development Configuration

An `application.yml` file is available for each service:

- `courier-service/src/main/resources/application.yml`
- `distance-service/src/main/resources/application.yml`
- `location-service/src/main/resources/application.yml`
- `store-service/src/main/resources/application.yml`
- `api-gateway-courier-tracking/src/main/resources/application.yml`

## 📝 Project Structure

```
courier-tracking/
├── courier-tracking-parent/        # Parent POM & Docker Compose
│   ├── pom.xml
│   ├── docker-compose.yml
│   └── docker/
├── api-gateway-courier-tracking/   # API Gateway Service
├── courier-service/                # Courier Service
├── distance-service/               # Distance Service
├── location-service/               # Location Service
└── store-service/                  # Store Service
```
