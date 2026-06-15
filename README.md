# 🚚 Courier Tracking System

Microservice-based courier tracking system built with **Java 21**, **Spring Boot 3**, **Kafka**, **PostgreSQL**, and *
*Couchbase**.

---

## 📐 Architecture

```
                        ┌────────────────────────────────────────────────────────────────────┐
                        │              API Gateway :8080                                     │
                        │        (Spring Cloud Gateway)                                      │
                        └────────┬──────────────┬──────────────┬──────────────────────┬──────┘
                                 │              │              │                      │
                    /locations   │  /stores     │  /distances  │                      │
                                 ▼              ▼              ▼                      ▼
                ┌──────────────────┐  ┌───────────────┐  ┌──────────────────┐ ┌──────────────────┐
                │ Location Service │  │ Store Service │  │ Distance Service │ │ Courier Service │
                │     :8081        │  │    :8082      │  │     :8085        │ │     :8083        │
                │  (PostgreSQL)    │  │  (Couchbase)  │  │MongoDB,Couchbase │ │  (PostgreSQL)    │
                └────────┬─────────┘  └───────┬───────┘  └────────┬─────────┘ └────────┬─────────┘
                         │                    ▲                   ▲                    ▲
                         │   Kafka Topic:     │                   │                    │
                         └──► courier.location.events ──────────►─┘──────────►───────►─┘
                                  (Observer Pattern)
```

### Services

| Service              | Port | DB                 | Role                                           |
|----------------------|------|--------------------|------------------------------------------------|
| **api-gateway**      | 8080 | —                  | Single entry point, routing                    |
| **location-service** | 8081 | PostgreSQL         | Accepts location input, publishes Kafka events |
| **store-service**    | 8082 | Couchbase          | 100m proximity check, 1-min reentry rule       |
| **distance-service** | 8085 | MongoDB, Couchbase | Accumulates total travel distance              |
| **courier-service**  | 8083 | PostgreSQL         | Courier information                            |

### Design Patterns Used

1. **Observer Pattern** — `LocationEventPublisher` (Subject) publishes to Kafka. `store-service` and `distance-service`
   are independent Observers.
2. **Strategy Pattern** — `DistanceCalculator` interface with `HaversineDistanceCalculator` implementation. Swap
   algorithms without changing service logic.
3. **Singleton Pattern** — `StoreInitializerService` loads `stores.json` once on startup into Couchbase.

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Java 21 (for local development)
- Maven 3.9+

### Run Everything with Docker

```bash
# 1. Clone and build all services
git clone <repo-url>
cd courier-tracking

# 2. Build JARs
mvn clean package -DskipTests

# 3. Start all infrastructure + microservices
chmod +x docker/postgres-init.sh docker/couchbase-init.sh
docker compose up --build

# Wait ~60 seconds for all services to start
```

Services will be available at:

- **API Gateway**: http://localhost:8080
- **Kafka UI**: http://localhost:9090
- **Couchbase UI**: http://localhost:8091 (admin / password123)

---

## 📡 API Reference

All requests go through the API Gateway on port **8080**.

### 1. Record Courier Location

```bash
POST http://localhost:8080/api/v1/locations
Content-Type: application/json

{
  "courierId": "courier-42",
  "lat": 40.9923307,
  "lng": 29.1244229,
  "time": "2024-03-15T10:30:00Z"
}
```

Response:

```json
{
  "id": 1,
  "courierId": "courier-42",
  "lat": 40.9923307,
  "lng": 29.1244229,
  "recordedAt": "2024-03-15T10:30:00Z",
  "message": "Location recorded and event dispatched"
}
```

### 2. Get Total Travel Distance

```bash
GET http://localhost:8080/api/v1/distances/courier-42/total
```

Response:

```json
{
  "courierId": "courier-42",
  "totalDistanceMeters": 1542.7,
  "totalDistanceKilometers": 1.5427,
  "lastUpdated": "2024-03-15T10:35:00Z"
}
```

### 3. Get Store Entrance Logs

```bash
GET http://localhost:8080/api/v1/stores/entrances/courier-42
```

Response:

```json
{
  "courierId": "courier-42",
  "totalEntrances": 2,
  "logs": [
    {
      "storeName": "Ataşehir",
      "distanceToStore": 45.3,
      "enteredAt": "2024-03-15T10:30:00Z"
    }
  ]
}
```

### 4. List All Migros Stores

```bash
GET http://localhost:8080/api/v1/stores
```

---

## 🧪 Testing

### Automated Test Scenario

```bash
# Send a courier near Ataşehir store (lat: 40.9923307, lng: 29.1244229)
# 1st location: ~50m from store → should log entrance
curl -X POST http://localhost:8080/api/v1/locations \
  -H "Content-Type: application/json" \
  -d '{
    "courierId": "test-courier",
    "lat": 40.9924,
    "lng": 29.1244,
    "time": "2024-03-15T10:00:00Z"
  }'

# 2nd location: same store, 30 seconds later → should NOT log (within 1-min cooldown)
curl -X POST http://localhost:8080/api/v1/locations \
  -H "Content-Type: application/json" \
  -d '{
    "courierId": "test-courier",
    "lat": 40.9923,
    "lng": 29.1243,
    "time": "2024-03-15T10:00:30Z"
  }'

# 3rd location: same store, 90 seconds later → should log entrance (cooldown elapsed)
curl -X POST http://localhost:8080/api/v1/locations \
  -H "Content-Type: application/json" \
  -d '{
    "courierId": "test-courier",
    "lat": 40.9923,
    "lng": 29.1243,
    "time": "2024-03-15T10:01:30Z"
  }'

# Check entrance logs (expect 2 entries)
curl http://localhost:8080/api/v1/stores/entrances/test-courier

# Check distance
curl http://localhost:8080/api/v1/distances/test-courier/total
```

### Unit Tests

```bash
mvn test
```

---

## 📁 Project Structure

```
courier-tracking/
├── pom.xml                          # Parent POM
├── docker-compose.yml
├── docker/
│   ├── postgres-init.sh             # Creates location_db + distance_db
│   └── couchbase-init.sh            # Bucket + index creation
│
├── api-gateway/                     # Spring Cloud Gateway :8080
│   └── src/main/resources/application.yml
│
├── location-service/                # Accepts location, publishes Kafka :8081
│   ├── Dockerfile
│   └── src/main/java/com/couriertracking/location/
│       ├── controller/LocationController.java
│       ├── service/LocationService.java
│       ├── kafka/LocationEventPublisher.java   ← Observer Subject
│       ├── util/DistanceCalculator.java        ← Strategy Interface
│       └── util/HaversineDistanceCalculator.java ← Strategy Impl
│
├── store-service/                   # Proximity checks, Couchbase :8082
│   └── src/main/java/com/couriertracking/store/
│       ├── kafka/LocationEventConsumer.java    ← Observer
│       ├── service/StoreProximityService.java  ← 100m + 1min logic
│       └── service/StoreInitializerService.java ← Singleton
│
└── distance-service/                # Distance accumulation, PostgreSQL :8083
    └── src/main/java/com/couriertracking/distance/
        ├── kafka/LocationEventConsumer.java    ← Observer
        └── service/DistanceService.java        ← getTotalTravelDistance()
```

---

## ⚙️ Environment Variables

| Variable                  | Default          | Used By            |
|---------------------------|------------------|--------------------|
| `POSTGRES_HOST`           | localhost        | location, distance |
| `POSTGRES_USER`           | courier          | location, distance |
| `POSTGRES_PASSWORD`       | courier123       | location, distance |
| `COUCHBASE_HOST`          | localhost        | store              |
| `COUCHBASE_USER`          | Administrator    | store              |
| `COUCHBASE_PASSWORD`      | password123      | store              |
| `COUCHBASE_BUCKET`        | courier_tracking | store              |
| `KAFKA_BOOTSTRAP_SERVERS` | localhost:9092   | all services       |
| `LOCATION_SERVICE_HOST`   | localhost        | api-gateway        |
| `STORE_SERVICE_HOST`      | localhost        | api-gateway        |
| `DISTANCE_SERVICE_HOST`   | localhost        | api-gateway        |

---

## 🔍 Monitoring

| URL                                   | Description     |
|---------------------------------------|-----------------|
| http://localhost:9090                 | Kafka UI        |
| http://localhost:8091                 | Couchbase Admin |
| http://localhost:8080/actuator/health | Gateway health  |
| http://localhost:8081/actuator/health | Location health |
| http://localhost:8082/actuator/health | Store health    |
| http://localhost:8083/actuator/health | Distance health |
