# vitaminav
A Flutter reader app designed for religious readings, that can be easily integrated and customized with different kinds of readable content.

VitaminaV is currently only available in Italian. The name translates to "Vitamin V", where "V" stands for "Vangelo" (gospel). Indeed the purpose of the app is to provide many short meditations on gospel passages, along with various other contents, that can be read as "nourishment" for the user's daily spiritual life.

## Structure
The application has a simple but highly modular structure.

### Home Screen
The home screen features a list of sections, corresponding to different types of readable contents (e.g. gospel mediations, saints' biographies, prayers). Each section can possibly be expandable, to reveal subsections.

A Material drawer provides a standard app menu, with the addition of an option to enable daily remainders at a given time.

### Navigation / Table of Contents
By tapping on one of the sections (or subsections) of the home screen the user begins to navigate the contents, with multiple possible interfaces. 

The ordinary interface, used in most cases, is a table of contents, that consists of a list of items corresponding to "pages", with a title and possibly a subtitle. Pressing on an item leads directly to a reader screen that display the actual contents of the page. In some cases, a special item appears at the beginning of the list to allow the user to resume reading from the last page and scroll position.

Other possible navigation interfaces are the Via Crucis screen, that displays the stations in a grid layout, and the Tags screen, that lists all the tags used in gospel meditations and allow to access a specific table of contents for each tag.

### Reader Screen
The Reader screen consists of a page view, where each page corresponds to a piece of readable content and is usually scrollable. The reader screen is often opened from a table of contents, and of course presents the page corresponding to the tapped item. The user however can still swipe left and right or use specific buttons to navigate all the pages of the table of contents.

The app bar of the Reader features buttons to persistently regulate the font size of the pages.

Each page is built dynamically only when needed, possibly loading contents from the database asynchronously. This allows great scalability and responsiveness independently of the number of pages.

## How to build
This is a Flutter app. Refer to [documentation](https://flutter.dev/docs/get-started/install) for instruction on how to install and use Flutter. Then simply open the contents of this repository as a Flutter project and run.

## Managing contents and customization
The readable contents are stored in a SQLite database located at [assets/vitaminav.db](assets/vitaminav.db), that currently contains placeholder content. Most contents are simply represented as rows in a table, with columns corresponding to different fields, depending on the content's structure. For example saints' biographies feature a title (usually the name of the saint) a subtitle (usually the dates of birth and death) and main text.

In the code the database is usually accessed both to list the items in a section/subsection and to actually build a page in the Reader screen, so modifications to the database structure will need to be reflected in both contexts.

With the current structure, the database can be easily built from an Excel file by using the node js utility located at [generation/db_builder](generation/db_builder). To build the database just edit the Excel file [db_source.xlsx](generation/db_builder/db_source.xlsx) (the structure should be self-explainatory) and run `node start`. The database will be built and saved in the assets folder, replacing the previous one. The utility works by reading contents from the Excel file and inserting them into a copy of [vitaminav.template.db](generation/db_builder/vitaminav.template.db), therefore 

**Be careful**: at first open the app will copy the database from assets to local storage, and then will always use the local copy. The database will be forcefully reloaded from assets any time the package version or build number changes. Therefore, if you update the database, remember to also update the version or build number in [pubspec.yaml](pubspec.yaml), or the changes may not appear.