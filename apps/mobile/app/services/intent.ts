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
import { Platform } from "react-native";
import { db } from "../common/database";
import { setAppState } from "../screens/editor/tiptap/utils";
import { eOnLoadNote } from "../utils/events";
import { OpenNotesModule } from "../utils/opennotes-module";
import { eSendEvent } from "./event-manager";
import { fluidTabsRef } from "../utils/global-refs";
import AddReminder from "../screens/add-reminder";

const launchIntent = Platform.OS === "ios" ? {} : OpenNotesModule.getIntent();
let used = false;
let launched = false;
export const IntentService = {
  getLaunchIntent() {
    if (used || Platform.OS === "ios") return null;
    used = true;
    return launchIntent;
  },
  onLaunch() {
    if (launched || Platform.OS === "ios") return;
    launched = true;
    if (launchIntent["com.openlay.opennotes.OpenNoteId"]) {
      setAppState({
        movedAway: false,
        editing: true,
        timestamp: Date.now(),
        noteId: launchIntent["com.openlay.opennotes.OpenNoteId"]
      });
    }
  },
  async onAppStateChanged() {
    if (Platform.OS === "ios") return;
    try {
      const intent = OpenNotesModule.getIntent();

      if (intent["com.openlay.opennotes.OpenNoteId"]) {
        const note = await db.notes.note(
          intent["com.openlay.opennotes.OpenNoteId"]
        );
        if (note) {
          eSendEvent(eOnLoadNote, {
            item: note
          });
          fluidTabsRef.current?.goToPage("editor", false);
        }
      } else if (intent["com.openlay.opennotes.OpenReminderId"]) {
        const reminder = await db.reminders.reminder(
          intent["com.openlay.opennotes.OpenReminderId"]
        );
        if (reminder) AddReminder.present(reminder);
      } else if (intent["com.openlay.opennotes.NewReminder"]) {
        AddReminder.present();
      }
    } catch (e) {
      /* empty */
    }
  }
};
