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

import { strings } from "@opennotes/intl";
import { CirclePartners } from "./components/circle-partners";
import { SettingsGroup } from "./types";

export const OpenNotesCircleSettings: SettingsGroup[] = [
  {
    header: strings.opennotesCircle(),
    key: "opennotes-circle",
    section: "circle",
    settings: [
      {
        key: "partners",
        title: "",
        description: strings.opennotesCircleDesc(),
        components: [
          {
            type: "custom",
            component: CirclePartners
          }
        ]
      }
    ]
  }
];
