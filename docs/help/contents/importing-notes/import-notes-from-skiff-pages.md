---
title: Skiff Pages
---

# How do I import notes from Skiff Pages?

The following steps will help you quickly import your notes from Skiff Pages into OpenNotes.

## Exporting your Skiff Pages

1. Open the [Skiff Pages](https://app.skiff.com) app
2. Open Settings > Export or just go directly to [https://app.skiff.com/dashboard/?settingTab=export](https://app.skiff.com/dashboard/?settingTab=export)
   ![](/static/skiff-importer/1.png)
3. Click on the Export button next to `Pages and Files` — this might take a few minutes depending on how many pages you have.
4. Once the export is complete, save the `Skiff.zip` file at your preferred location.
   ![](/static/skiff-importer/2.png)

## Importing Skiff.zip file into OpenNotes

Once you have the `Skiff.zip` file containing your Skiff pages, its time to import them into OpenNotes.

1. Open the OpenNotes app (web or desktop)
2. Go to `Settings > OpenNotes Importer` and select "Skiff Pages".
   ![](/static/skiff-importer/3.png)
3. Drop your Skiff.zip file, or click anywhere inside the box to browse and select your Skiff.zip file. Then click "Start processing".
   ![](/static/skiff-importer/4.png)
4. Once the importing completes you should see all your notes in OpenNotes. If you face any issues during importing, feel free to [report them on GitHub](https://github.com/openlay/opennotes-importer).

## Supported formats

- [x] Images
- [x] Code blocks
- [ ] Math blocks (Skiff Pages doesn't mark them properly so there's no way to detect them.)
- [x] Tables
- [x] Rich text (bold, italic, headings, lists etc.)
- [x] Task lists
