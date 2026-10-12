BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sos_incident" (
    "id" bigserial PRIMARY KEY,
    "incidentId" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "status" text NOT NULL,
    "severity" text NOT NULL,
    "description" text,
    "sourceDeviceId" text,
    "relayCount" bigint NOT NULL,
    "lastUpdatedAt" timestamp without time zone NOT NULL,
    "claimedBy" text,
    "resolvedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "sos_incident_incident_id_unique_idx" ON "sos_incident" USING btree ("incidentId");
CREATE INDEX "sos_incident_status_idx" ON "sos_incident" USING btree ("status");
CREATE INDEX "sos_incident_created_at_idx" ON "sos_incident" USING btree ("createdAt");


--
-- MIGRATION VERSION FOR jivaan_net
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('jivaan_net', '20261011152425421', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261011152425421', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
