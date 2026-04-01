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
import { Note } from "@opennotes/core";
import { db } from "../common/database";
import { OpenNotesModule } from "../utils/opennotes-module";
import { Platform } from "react-native";

let timer: NodeJS.Timeout;
export const NotePreviewWidget = {
  updateNotes: () => {
    if (Platform.OS !== "android") return;
    clearTimeout(timer);
    timer = setTimeout(async () => {
      const noteIds = await OpenNotesModule.getWidgetNotes();
      for (const id of noteIds) {
        const newNote = await db.notes.note(id);
        if (!newNote) continue;

        OpenNotesModule.updateWidgetNote(id, JSON.stringify(newNote));
      }
    }, 500);
  },
  updateNote: async (id: string, note: Note) => {
    if (Platform.OS !== "android") return;
    if (id && (await OpenNotesModule.hasWidgetNote(id))) {
      OpenNotesModule.updateWidgetNote(id, JSON.stringify(note));
    }
  }
};
