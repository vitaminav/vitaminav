// This simple utility builds the SQLite database vitaminav.db content from the db_cource.xlsx file

async function main() {
    const readXlsxFile = require('read-excel-file/node');
    const sqlite3 = require('sqlite3');
    var fs = require('fs');

    const inputFile = 'db_source.xlsx';
    const dbTemplate = 'vitaminav.template.db';
    const dbTarget = '../../assets/vitaminav.db';

    // Copy template to target
    fs.createReadStream(dbTemplate).pipe(fs.createWriteStream(dbTarget));

    // Read data from the excel source
    try {
        evangelium_rows = await readXlsxFile(inputFile, { sheet: 1 });
        evangelium_rows.shift(); // Remove heading row
        viacrucis_rows = await readXlsxFile(inputFile, { sheet: 2 });
        viacrucis_rows.shift(); // Remove heading row
        pontifex_rows = await readXlsxFile(inputFile, { sheet: 3 });
        pontifex_rows.shift(); // Remove heading row
        saints_rows = await readXlsxFile(inputFile, { sheet: 4 });
        saints_rows.shift(); // Remove heading row
        prayers_rows = await readXlsxFile(inputFile, { sheet: 5 });
        prayers_rows.shift(); // Remove heading row
    } catch (error) {
        console.error(error);
    }

    const db = await new Promise((resolve, _reject) => {
        const self = new sqlite3.Database(dbTarget, sqlite3.OPEN_READWRITE, (err) => {
            if (err) {
                reject(err);
            } else { resolve(self); }
        })
    });

    index = 0;

    db.serialize(() => {
        // Prepare
        db.run('DELETE FROM evangelium');
        db.run('DELETE FROM evangelium_tags');
        db.run('DELETE FROM viacrucis');
        db.run('DELETE FROM pontifex');
        db.run('DELETE FROM saints');
        db.run('DELETE FROM prayers');

        let evInsertStatement = db
            .prepare('INSERT INTO evangelium (book, chapter, verse0, verse1, title, quote, comment) VALUES(?, ?, ?, ?, ?, ?, ?)');

        let tagInsertStatement = db
            .prepare('INSERT INTO evangelium_tags (tag, evangelium_id) VALUES(?, ?)');

        let vcInsertStatement = db
            .prepare('INSERT INTO viacrucis (number, title, image, caption, comment, author, copyright) VALUES (?, ?, ?, ?, ?, ?, ?)');

        let poInsertStatement = db
            .prepare('INSERT INTO pontifex (author, title, date, text) VALUES (?, ?, ?, ?)');

        let saInsertStatement = db
            .prepare('INSERT INTO saints (title, subtitle, text, copyright) VALUES (?, ?, ?, ?)');

        let prInsertStatement = db
            .prepare('INSERT INTO prayers (category, title, text) VALUES (?, ?, ?)');

        // Evangelium and tags
        evangelium_rows.forEach(row => {
            // Extract tags
            const tags = String(row[6]).split(',').map((tag) => tag.trim().toLowerCase());

            // Insert evangelium
            evInsertStatement.run(row[0], row[1], row[2], row[3], row[4], row[7], row[8], (error) => {
                if (error) {
                    reject(error);
                }
                // Insert tags
                tags.forEach((tag) => {
                    tagInsertStatement.run(tag, evInsertStatement.lastID);
                });
            });
        });

        // Via crucis
        viacrucis_rows.forEach(row => {
            vcInsertStatement.run(...row);
        });

        // Pontifex
        pontifex_rows.forEach(row => {
            poInsertStatement.run(...row);
        });

        // Saints
        saints_rows.forEach(row => {
            saInsertStatement.run(...(row.map(cell => cell ? cell : '')));
        });

        // Prayers
        prayers_rows.forEach(row => {
            prInsertStatement.run(...row);
        });
    });
}

main();