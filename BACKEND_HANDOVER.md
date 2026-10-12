# JivaanNet Backend Handover Documentation

This document provides complete technical specifications, architectural details, and practical guidance for integrating the **JivaanNet** Serverpod backend with the Flutter frontend application.

---

## 1. Project Architecture & Repository Folder Structure

JivaanNet uses **Serverpod 4.0.4** with an embedded **PostgreSQL 16** database. The repository is organized into distinct packages for server and client:

```text
JivaanNet/
├── BACKEND_HANDOVER.md             # This comprehensive handover guide
├── BACKEND_STATUS.md               # Quick status checklist & audit report
└── jivaan_net/
    ├── jivaan_net_server/          # Serverpod backend application
    │   ├── bin/main.dart           # Server entry point
    │   ├── config/                 # Environment configurations (development, test, staging, production)
    │   ├── lib/
    │   │   ├── server.dart         # Server initialization, auth services, cloud storage
    │   │   └── src/
    │   │       ├── auth/           # Authentication endpoints (email IDP, JWT refresh)
    │   │       ├── generated/      # Serverpod generated protocol code & endpoints
    │   │       ├── greetings/      # Baseline greeting endpoint & protocol
    │   │       ├── incidents/      # SOS incident models, validation, lifecycle endpoints
    │   │       └── triage/         # Deterministic rule-based emergency triage service
    │   ├── migrations/             # Database schema migrations & migration registry
    │   └── test/                   # Integration, unit, and concurrency tests (40 tests)
    │
    └── jivaan_net_client/          # Auto-generated client package consumed by Flutter
        ├── lib/
        │   ├── jivaan_net_client.dart  # Main library export
        │   └── src/protocol/           # Generated client models, exceptions & endpoints
        └── pubspec.yaml
```

---

## 2. Prerequisites & Running the Backend Locally

### Prerequisites
* **Dart SDK**: 3.13.x or compatible Flutter SDK
* **Serverpod CLI**: Version 4.0.4 (`dart pub global activate serverpod_cli 4.0.4`)

### Starting the Development Server
From the root directory:
```bash
cd jivaan_net/jivaan_net_server
serverpod start
```
* The Serverpod runner automatically launches the embedded PostgreSQL database, runs hot reload, and serves the API.
* Main API endpoint: `http://localhost:8080/`
* Insights dashboard: `http://localhost:8081/`

---

## 3. Database Configuration & Migration Workflow

* **Embedded PostgreSQL**: Serverpod bundles and manages an embedded PostgreSQL instance storing its data in `jivaan_net/jivaan_net_server/.serverpod/development/pgdata`. No external Docker or manual PostgreSQL installation is required for local development.
* **Applied Migrations**:
  * `20261011150326026`: Serverpod auth and baseline tables.
  * `20261011152425421`: `sos_incident` table, unique index on `incidentId`, and secondary indexes on `status` and `createdAt`.
* **Applying Pending Migrations**:
  If the server is started via `serverpod start`, migrations are applied automatically. If running the server binary directly:
  ```bash
  dart run bin/main.dart --apply-migrations
  ```
  Or for a standalone maintenance run without binding HTTP listener ports:
  ```bash
  dart run bin/main.dart --role maintenance --apply-migrations
  ```
* **Creating Future Migrations**:
  When modifying model `.spy.yaml` files:
  ```bash
  serverpod create-migration
  ```

---

## 4. How to Import `jivaan_net_client` in Flutter

In your Flutter app's `pubspec.yaml`, add `jivaan_net_client` as a path dependency:

```yaml
dependencies:
  flutter:
    sdk: flutter
  jivaan_net_client:
    path: ../jivaan_net/jivaan_net_client
  serverpod_flutter: ^4.0.4
  serverpod_auth_shared_flutter: ^4.0.4
```

Then run `flutter pub get`.

---

## 5. Client Initialization in Flutter

Initialize the Serverpod client in your Flutter app (typically in `main.dart` or a dependency injection container):

```dart
import 'package:flutter/material.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

late final Client client;
late final SessionManager sessionManager;

Future<void> initializeBackendClient({required String serverUrl}) async {
  client = Client(
    serverUrl,
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  sessionManager = SessionManager(
    caller: client.modules.serverpod_auth_core,
  );
  await sessionManager.initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // See Section 9 for selecting the correct URL per device
  await initializeBackendClient(serverUrl: 'http://10.0.2.2:8080/');
  
  runApp(const MyApp());
}
```

---

## 6. Incident API Endpoints & Contract

All incident methods are available under `client.incident`:

### 6.1 `submitSos` — Ingest SOS Incident
Ingests an emergency alert submitted by a mobile client or relayed over mesh networking.

* **Method**: `Future<SosSubmissionResponse> submitSos(SosSubmissionPayload payload)`
* **Authorization**: Public (No authentication required).
* **Payload Fields (`SosSubmissionPayload`)**:
  | Field | Type | Required | Constraints / Description |
  | :--- | :--- | :--- | :--- |
  | `incidentId` | `String` | **Yes** | Valid UUID (v4 format). Serves as client idempotency key. |
  | `latitude` | `double` | **Yes** | Finite number between `-90.0` and `90.0`. |
  | `longitude` | `double` | **Yes** | Finite number between `-180.0` and `180.0`. |
  | `createdAt` | `DateTime` | **Yes** | UTC device creation timestamp. Must not be $>15$ mins in future or before year 2020. |
  | `description` | `String?` | No | Emergency description/notes (max 2000 chars). Analyzed by server triage. |
  | `sourceDeviceId` | `String?` | No | Pseudonymous hardware/client device ID (max 255 chars). |
  | `relayCount` | `int` | **Yes** | Number of mesh hops ($0 \le \text{relayCount} \le 1000$). |

* **Response Model (`SosSubmissionResponse`)**:
  * `incident` (`SosIncident`): The persisted incident record.
  * `isNew` (`bool`): `true` if this submission created a new record; `false` if it was already ingested (duplicate).
  * `message` (`String`): Descriptive status text.

* **Idempotency & Duplicate Handling**:
  Submitting the same `incidentId` multiple times is safe and will **not** create duplicate rows or overwrite existing incident records or severity levels. If an incident with the given `incidentId` already exists, the server returns the existing record with `isNew: false`.

* **Exceptions**:
  * `SosValidationException`: Thrown if coordinates are invalid, UUID is malformed, timestamp drift exceeds bounds, or text exceeds limits.

---

### 6.2 `getIncident` — Retrieve Single Incident
Retrieves details for a single incident by its UUID.

* **Method**: `Future<SosIncident?> getIncident(String incidentId)`
* **Authorization**: Public (No authentication required).
* **Returns**: `SosIncident?` (`null` if no incident matches the UUID).
* **Exceptions**: `SosValidationException` if `incidentId` is not a valid UUID format.

---

### 6.3 `listIncidents` — Paginated & Filtered Listing
Lists incidents ordered by `createdAt DESC, id DESC`.

* **Method**:
  ```dart
  Future<IncidentListPage> listIncidents({
    required int page,
    required int limit,
    String? status,
    String? severity,
    DateTime? fromDate,
    DateTime? toDate,
  })
  ```
* **Authorization**: Public (No authentication required).
* **Parameters**:
  * `page` (`int`, default `1`): 1-indexed page number ($\ge 1$).
  * `limit` (`int`, default `20`): Page size, clamped strictly to $1 \le \text{limit} \le 100$.
  * `status` (`String?`): Optional status filter (`pending`, `acknowledged`, `dispatched`, `resolved`).
  * `severity` (`String?`): Optional severity filter (`critical`, `high`, `medium`, `low`).
  * `fromDate` (`DateTime?`): Optional lower bound for `createdAt`.
  * `toDate` (`DateTime?`): Optional upper bound for `createdAt`.
* **Returns (`IncidentListPage`)**:
  * `incidents` (`List<SosIncident>`): Records on the current page.
  * `totalCount` (`int`): Total matching records.
  * `page` (`int`): Current page index.
  * `pageSize` (`int`): Page size used.
  * `hasMore` (`bool`): `true` if subsequent pages exist.

---

### 6.4 `claimIncident` — Responder Claiming
Claims an unclaimed incident for the authenticated responder.

* **Method**: `Future<SosIncident> claimIncident(String incidentId)`
* **Authorization**: **Required** (`dispatcher` or `admin` scope).
* **Concurrency Protection**: Uses PostgreSQL `LockMode.forUpdate` inside an atomic transaction. If two responders simultaneously claim the same incident, exactly one succeeds and the other receives a conflict exception.
* **Idempotency**: If the *same* responder calls `claimIncident` again on an incident they already claimed, it returns the incident successfully without error.
* **Transitions**: If the incident is `pending`, its status transitions to `acknowledged`.
* **Exceptions**:
  * `SosAuthorizationException`: If unauthenticated or caller lacks `dispatcher`/`admin` scope.
  * `SosNotFoundException`: If `incidentId` does not exist.
  * `SosValidationException`: If the incident is already `resolved`.
  * `SosClaimConflictException`: If the incident is already claimed by another responder (`claimedBy` field indicates who holds the claim).

---

### 6.5 `updateIncidentStatus` — Status Transition
Advances the lifecycle status of an incident.

* **Method**: `Future<SosIncident> updateIncidentStatus(String incidentId, String newStatus)`
* **Authorization**: **Required** (`dispatcher` or `admin` scope).
* **Valid Statuses**: `pending`, `acknowledged`, `dispatched`, `resolved`.
* **Allowed Transition State Machine**:
  * `pending` $\to$ `acknowledged`, `dispatched`, `resolved`
  * `acknowledged` $\to$ `dispatched`, `resolved`
  * `dispatched` $\to$ `resolved`
  * `resolved` $\to$ `resolved` (idempotent no-op)
* **Exceptions**:
  * `SosAuthorizationException`: If caller lacks `dispatcher`/`admin` scope.
  * `SosNotFoundException`: If incident does not exist.
  * `SosValidationException`: If the transition is disallowed or status is invalid.

---

### 6.6 `resolveIncident` — Mark Incident Resolved
Marks an incident as resolved and timestamps its resolution.

* **Method**: `Future<SosIncident> resolveIncident(String incidentId)`
* **Authorization**: **Required** (`dispatcher` or `admin` scope).
* **Idempotency**: Repeated calls on an already-resolved incident are idempotent.
* **Behavior**: Sets `status = 'resolved'`, `lastUpdatedAt = now`, and `resolvedAt = now` (if not already set).

---

## 7. Offline SOS Creation & Mesh Relay Synchronization

Mobile clients and offline mesh relays should handle SOS creation and ingestion as follows:

1. **UUID Generation**: When a user triggers SOS offline, generate a UUIDv4 on the device immediately and record the local timestamp as `createdAt`.
2. **Local Persistence**: Store this payload in your local offline SQLite / Hive queue.
3. **Mesh Relay / Delayed Upload**: When connectivity (cellular, Wi-Fi, or gateway mesh node) is restored, call `client.incident.submitSos(payload)`.
4. **Idempotency Guarantee**: If multiple mesh peers relay the identical SOS payload to the server, Serverpod's database uniqueness constraint on `incidentId` ensures:
   * Only one record is inserted.
   * Duplicate submissions receive `isNew: false` along with the original record.
   * `severity`, `createdAt`, and `description` are never modified or degraded by duplicate submissions.

---

## 8. Deterministic Severity Triage Rules

Severity is **strictly server-assigned** and cannot be spoofed or set directly by clients. When `submitSos` is processed, `DeterministicTriageService` classifies the priority:

* **`critical`**: Matches life-threatening keywords in the description:
  `collapse`, `collapsed`, `trapped`, `buried`, `drowning`, `cardiac`, `unconscious`, `severe bleeding`, `suffocation`, `explosion`, `mass casualty`, `crush`, `crushed`, `choking`.
* **`high`**: Matches injury, disaster, or active hazard keywords:
  `injured`, `injury`, `fracture`, `broken bone`, `bleeding`, `fire`, `smoke`, `flood`, `flooding`, `landslide`, `hazard`, `gas leak`, `electric shock`, `hypothermia`, `burn`, `burned`, `urgent`.
* **`low`**: Matches supply requests or non-critical status queries:
  `supplies`, `food needed`, `water needed`, `blanket`, `minor`, `safe`, `information`, `query`, `status check`.
* **`medium` (Default)**: Assigned when the description is empty or contains no recognized keywords (conservative disaster response baseline).

---

## 9. Development URLs & Device Networking Differences

Serverpod listens on `port 8080` on the development host machine. When connecting from Flutter:

| Client Environment | Correct Base URL | Notes |
| :--- | :--- | :--- |
| **Flutter Web (Chrome)** | `http://localhost:8080/` | Standard localhost. |
| **Flutter Desktop (Windows)** | `http://localhost:8080/` | Standard localhost. |
| **Android Emulator** | `http://10.0.2.2:8080/` | `10.0.2.2` routes to host loopback interface. |
| **Physical Android Phone (USB)** | `http://localhost:8080/` | **Requires ADB Reverse**: Run `adb reverse tcp:8080 tcp:8080` in terminal. |
| **Physical Android Phone (Wi-Fi)** | `http://<HOST_LAN_IP>:8080/` | Replace with host IP (e.g. `192.168.1.50`). Ensure Windows Firewall allows port 8080. |
| **iOS Simulator** | `http://localhost:8080/` | Standard localhost. |

> **Warning for Physical Android Devices**: A physical phone cannot reach `http://localhost:8080/` directly without ADB reverse tethering. If connecting over Wi-Fi, ensure your phone and computer are on the same local network.

---

## 10. Running Tests & Diagnostics

To run the complete automated test suite:
```bash
cd jivaan_net/jivaan_net_server
dart test
```

### Common Diagnostics:
* **"Port 8080 or 8081 already in use"**: Check running Dart processes with `Get-Process dartvm, dartaotruntime` and terminate stale instances if needed.
* **"Table sos_incident is missing"**: Run `dart run bin/main.dart --role maintenance --apply-migrations` to apply pending migrations.
* **"Generated code mismatch"**: Run `serverpod generate` from `jivaan_net_server`.

---

## 11. Dispatcher & Admin Scope Provisioning

### Current Implementation
* Serverpod authentication uses `Scope('dispatcher')` and `Scope('admin')` for authorization on `claimIncident`, `updateIncidentStatus`, and `resolveIncident`.
* Public user registration via `client.emailIdp` creates standard authenticated users with **no administrative scopes**.
* **Security Guardrail**: The backend does **not** provide an open role-granting endpoint, nor does it assign `dispatcher` automatically to new registrations.

### Operational Provisioning Approach
To grant dispatcher permissions to a user for development/staging:
1. Register the user account via Flutter or the Auth API.
2. An administrator or seed script assigns the `dispatcher` scope in PostgreSQL table `serverpod_user_info`:
   ```sql
   UPDATE serverpod_user_info
   SET "scopes" = '["dispatcher"]'
   WHERE "email" = 'responder@jivaannet.org';
   ```
3. Or provision test accounts programmatically in server code via `UserInfo.db.updateRow`.

---

## 12. Next Tasks for Durgesh (Frontend Integration)

1. **Add Dependency**: Link `jivaan_net_client: path: ../jivaan_net/jivaan_net_client` in the Flutter app's `pubspec.yaml`.
2. **Initialize Client**: Wire the `Client` singleton with the correct base URL based on device detection or environment configuration.
3. **Connect SOS Trigger Button**: Hook the emergency button up to `client.incident.submitSos(...)`, passing device coordinates and generated UUID.
4. **Implement Offline Queue**: Store unsent `SosSubmissionPayload` items in a local SQLite/Hive database when offline, retrying via `submitSos` when connectivity returns.
5. **Implement Dispatcher Dashboard**: Use `client.incident.listIncidents(...)` with status/severity filters, and provide claim/status action buttons calling `claimIncident`, `updateIncidentStatus`, and `resolveIncident`.
