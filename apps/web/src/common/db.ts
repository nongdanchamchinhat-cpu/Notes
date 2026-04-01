/*
This file is part of the OpenNotes project (https://opennotes.openlay.com/)

Copyright (C) 2023 OpenLay (Private) Limited

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import { EventSourcePolyfill as EventSource } from "event-source-polyfill";
import { DatabasePersistence, NNStorage } from "../interfaces/storage";
import { database, getFeature, getFeatureLimit } from "@opennotes/common";
import { createDialect } from "./sqlite";
import { isFeatureSupported } from "../utils/feature-check";
import { generatePassword } from "../utils/password-generator";
import { deriveKey, useKeyStore } from "../interfaces/key-store";
import { hosts, SubscriptionPlan, SubscriptionStatus } from "@opennotes/core";
import Config from "../utils/config";
import { FileStorage } from "../interfaces/fs";

function getHostUrl(hostUrl: keyof typeof hosts, defaultUrl: string) {
  if (IS_TESTING) return defaultUrl;
  const envValue = import.meta.env[`NN_${hostUrl}`];
  return envValue || defaultUrl;
}

const db = database;
async function initializeDatabase(persistence: DatabasePersistence) {
  performance.mark("start:initializeDatabase");

  let databaseKey = await useKeyStore.getState().getValue("databaseKey");
  if (!databaseKey) {
    databaseKey = await deriveKey(generatePassword());
    await useKeyStore.getState().setValue("databaseKey", databaseKey);
  }

  db.host({
    API_HOST: getHostUrl("API_HOST", "https://api.opennotes.openlay.com"),
    AUTH_HOST: getHostUrl("AUTH_HOST", "https://auth.openlay.co"),
    SSE_HOST: getHostUrl("SSE_HOST", "https://events.openlay.co"),
    ISSUES_HOST: getHostUrl("ISSUES_HOST", "https://issues.openlay.co"),
    SUBSCRIPTIONS_HOST: getHostUrl(
      "SUBSCRIPTIONS_HOST",
      "https://subscriptions.openlay.co"
    ),
    MONOGRAPH_HOST: getHostUrl("MONOGRAPH_HOST", "https://monogr.ph"),
    OPENNOTES_HOST: getHostUrl("OPENNOTES_HOST", "https://opennotes.openlay.com"),
    ...Config.get("serverUrls", {})
  });

  const storage = new NNStorage(
    "OpenNotes",
    () => useKeyStore.getState(),
    persistence
  );
  await storage.migrate();

  const multiTab = !!globalThis.SharedWorker && isFeatureSupported("opfs");
  database.setup({
    sqliteOptions: {
      dialect: (name, init) =>
        createDialect({
          name: persistence === "memory" ? ":memory:" : name,
          encrypted: persistence !== "memory",
          async: !isFeatureSupported("opfs"),
          init,
          multiTab
        }),
      ...(IS_DESKTOP_APP || isFeatureSupported("opfs")
        ? { journalMode: "WAL", lockingMode: "exclusive" }
        : {
            journalMode: "MEMORY",
            lockingMode: "normal"
          }),
      tempStore: "memory",
      synchronous: "normal",
      pageSize: 8192,
      cacheSize: -32000,
      password:
        persistence === "memory"
          ? undefined
          : Buffer.from(databaseKey).toString("hex"),
      skipInitialization: !IS_DESKTOP_APP && multiTab
    },
    storage: storage,
    eventsource: EventSource,
    fs: FileStorage,
    compressor: () =>
      import("../utils/compressor").then(({ Compressor }) => new Compressor()),
    maxNoteVersions: async () => {
      const limit = await getFeatureLimit(getFeature("maxNoteVersions"));
      return typeof limit.caption === "number" ? limit.caption : undefined;
    },
    batchSize: 100
  });

  // if (IS_TESTING) {

  // } else {
  // db.host({
  //   API_HOST: "http://localhost:5264",
  //   AUTH_HOST: "http://localhost:8264",
  //   SSE_HOST: "http://localhost:7264",
  // });
  // const base = `http://localhost`;
  // db.host({
  //   API_HOST: `${base}:5264`,
  //   AUTH_HOST: `${base}:8264`,
  //   SSE_HOST: `${base}:7264`,
  //   ISSUES_HOST: `${base}:2624`,
  //   SUBSCRIPTIONS_HOST: `${base}:9264`
  // });
  // }

  performance.mark("start:initdb");
  await db.init();
  performance.mark("end:initdb");

  if (db.migrations?.required()) {
    await import("../dialogs/migration-dialog").then(({ MigrationDialog }) =>
      MigrationDialog.show({})
    );
  }

  performance.mark("end:initializeDatabase");

  if (IS_TESTING && "isPro" in window) {
    await db.user.setUser({
      // @ts-expect-error just for testing purposes
      subscription: {
        plan: SubscriptionPlan.PRO,
        status: SubscriptionStatus.ACTIVE
      }
    });
  }

  return db;
}

export { db, initializeDatabase };
