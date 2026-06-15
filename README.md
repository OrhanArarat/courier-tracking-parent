# Courier Tracking System

Kurye takip sistemi, mikro servisler mimarisini kullanan, uygun ölçeklendirme ve yüksek performans için tasarlanmış bir
Spring Boot uygulamasıdır.

## 📋 Proje Özeti

Courier Tracking System, kuryelerin, depoların ve siparişlerin yönetimini sağlayan dağıtılmış bir sistem. Her servis,
kendi sorumluluğu altında çalışır ve mesaj kuyruğu üzerinden asenkron iletişim yapar.

## 🏗️ Sistem Mimarisi

```
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway Port 8080                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Courier    │  │   Distance   │  │   Location   │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  │  (Port 8081) │  │ (Port 8082)  │  │ (Port 8083)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                 │                  │              │
│  ┌──────────────┐                                          │
│  │    Store     │                                          │
│  │   Service    │                                          │
│  │ (Port 8084)  │                                          │
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

## 🛠️ Teknoloji Stack

| Bileşen      | Sürüm    | Amaç                 |
|--------------|----------|----------------------|
| Java         | 21       | Program dili         |
| Spring Boot  | 3.2.3    | Framework            |
| Spring Cloud | 2023.0.0 | Mikro servisler      |
| PostgreSQL   | 16       | İlişkisel veritabanı |
| Couchbase    | 7.6.1    | NoSQL veritabanı     |
| MongoDB      | 5.0      | Doküman veritabanı   |
| Kafka        | 7.6.0    | Mesaj kuyruğu        |
| Docker       | -        | Konteynerizasyon     |
| Maven        | 3.x      | Bağımlılık yönetimi  |

## 📦 Servisler

### 1. API Gateway

- **Port:** 8080
- **Açıklama:** Tüm isteklerin giriş noktası. Routlama, load balancing ve authentication sağlar.
- **Teknoloji:** Spring Cloud Gateway

### 2. Courier Service

- **Port:** 8081
- **Açıklama:** Kurye bilgilerinin yönetimi ve işlenmesi
- **Veritabanı:** PostgreSQL + Couchbase
- **Teknoloji:** Spring Data JPA, QueryDSL, Liquibase

### 3. Distance Service

- **Port:** 8082
- **Açıklama:** Mesafe hesaplama ve optimizasyon algoritmaları
- **Veritabanı:** MongoDB + Couchbase
- **Teknoloji:** Spring Data MongoDB

### 4. Location Service

- **Port:** 8083
- **Açıklama:** Konum tabanlı servisler
- **Teknoloji:** Spring Boot Web

### 5. Store Service

- **Port:** 8084
- **Açıklama:** Depo bilgilerinin yönetimi
- **Teknoloji:** Spring Boot Web

## 🚀 Başlangıç

### Ön Gereksinimler

- Java 21 kurulu olmalı
- Maven 3.8.0 veya üzeri
- Docker & Docker Compose
- Git

### Kurulum Adımları

1. **Projeyi klonlayın:**

```bash
git clone <repository-url>
cd courier-tracking
```

2. **Altyapıyı başlatın:**

```bash
cd courier-tracking-parent
docker-compose up -d
```

Docker Compose aşağıdaki servisleri başlatacak:

- PostgreSQL
- Couchbase
- MongoDB
- Kafka & Zookeeper
- Kafka UI
- Mongo Express

3. **Projeyi derleyin:**

```bash
cd courier-tracking-parent
mvn clean install
```

4. **Servisleri başlatın (her biri için ayrı terminal):**

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

## 🔌 Veritabanı Bağlantı Bilgileri

| Veritabanı | Host      | Port      | Kullanıcı | Şifre      |
|------------|-----------|-----------|-----------|------------|
| PostgreSQL | localhost | 5432      | courier   | courier123 |
| MongoDB    | localhost | 27017     | -         | -          |
| Couchbase  | localhost | 8091-8097 | admin     | password   |
| Kafka      | localhost | 9092      | -         | -          |

### Veritabanı Arayüzleri

- **Kafka UI:** http://localhost:9090
- **Mongo Express:** http://localhost:7071
- **Couchbase:** http://localhost:8091

## 📡 API Ağ Geçidi

Tüm API istekleri API Gateway üzerinden yapılır:

```
curl -X GET http://localhost:8080/api/v1/couriers
curl -X GET http://localhost:8080/api/v1/distances
curl -X GET http://localhost:8080/api/v1/locations
curl -X GET http://localhost:8080/api/v1/stores
```

## 🧪 Testler

Bütün testleri çalıştırmak için:

```bash
cd courier-tracking-parent
mvn test
```

Specific servisi test etmek için:

```bash
cd courier-service
mvn test
```

## 🐳 Docker ile Deployment

Her servis için Dockerfile mevcuttur. Tüm servisleri Docker ile çalıştırmak için:

```bash
cd courier-tracking-parent
docker-compose -f docker-compose.yml up -d
```

## 📊 Lokal Geliştirme Configuration

Her servis için `application.yml` dosyası mevcuttur:

- `courier-service/src/main/resources/application.yml`
- `distance-service/src/main/resources/application.yml`
- `location-service/src/main/resources/application.yml`
- `store-service/src/main/resources/application.yml`
- `api-gateway-courier-tracking/src/main/resources/application.yml`

## 📝 Proje Yapısı

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
