---
title: Google Keep
---

# How do I import notes from Google Keep?

The following steps will help you quickly import your notes from Google Keep into OpenNotes.

## Exporting your Google Keep notes

1. Go to [Google Takeout](https://takeout.google.com/settings/takeout) and log into your Google account.
2. On the Google Takeout page, first deselect all the items by clicking on `Deselect all`, and then scroll down and select only `Keep` from the list. Once selected, click on `Next Step` by scrolling to the very bottom of the page.
   ![](/static/google-keep-importer/1.png)
3. On the next section, leave everything as is and just click on the "Create export" button:
   ![](/static/google-keep-importer/2.png)
4. Download the exported .zip file once it becomes available:
   ![](/static/google-keep-importer/3.png)

## Importing Google Takeout into OpenNotes

Once you have the Google Takeout containing your Google Keep notes, its time to import them into OpenNotes.

1. Open the OpenNotes app (web or desktop)
2. Go to `Settings > OpenNotes Importer` and select `Google Keep` from list of apps.
   ![](/static/google-keep-importer/4.png)
3. Drop the .zip backup file(s) you exported earlier from Google Takeout in the box or click anywhere to open system file picker to select the backup.
   ![](/static/google-keep-importer/5.png)
4. Once the importing completes you should see all your notes in OpenNotes. If you face any issues during importing, feel free to [report them on GitHub](https://github.com/openlay/opennotes-importer).

## Supported formats

OpenNotes Importer is one of the most robust Google Keep importers around supporting almost 100% of Google Keep formats. Here's a list of everything that can (or can't be) imported into OpenNotes:

- [x] Attachments
- [x] Images
- [x] Checklists & other lists
- [x] Links
- [x] Tags/Labels
- [x] Pinned status
- [x] Colors
