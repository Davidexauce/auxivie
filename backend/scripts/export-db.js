const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

// Chemin de la base de données
const dbPath = path.join(__dirname, '..', 'data', 'auxivie.db');
const outputPath = path.join(__dirname, '..', 'data', 'auxivie-export.sql');

console.log('📦 Export de la base de données...');
console.log('Base de données source:', dbPath);

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Erreur ouverture base de données:', err.message);
    process.exit(1);
  }
  console.log('✅ Base de données ouverte');
});

// Fonction pour exporter une table
function exportTable(tableName) {
  return new Promise((resolve, reject) => {
    db.all(`SELECT * FROM ${tableName}`, [], (err, rows) => {
      if (err) {
        console.error(`⚠️ Erreur export table ${tableName}:`, err.message);
        return resolve([]);
      }
      resolve(rows);
    });
  });
}

// Fonction pour obtenir le schéma d'une table
function getTableSchema(tableName) {
  return new Promise((resolve, reject) => {
    db.all(`PRAGMA table_info(${tableName})`, [], (err, rows) => {
      if (err) {
        return reject(err);
      }
      resolve(rows);
    });
  });
}

// Fonction pour générer le SQL INSERT
function generateInsertSQL(tableName, rows, schema) {
  if (rows.length === 0) return '';
  
  const columns = schema.map(col => col.name).join(', ');
  const values = rows.map(row => {
    const vals = schema.map(col => {
      const val = row[col.name];
      if (val === null) return 'NULL';
      if (typeof val === 'string') {
        return `'${val.replace(/'/g, "''")}'`;
      }
      return val;
    });
    return `(${vals.join(', ')})`;
  });
  
  return `INSERT INTO ${tableName} (${columns}) VALUES\n${values.join(',\n')};\n\n`;
}

// Fonction principale
async function exportDatabase() {
  try {
    // Liste des tables
    const tables = await new Promise((resolve, reject) => {
      db.all("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'", [], (err, rows) => {
        if (err) return reject(err);
        resolve(rows.map(r => r.name));
      });
    });

    console.log(`📋 Tables trouvées: ${tables.length}`);
    console.log(tables.join(', '));

    let sqlContent = `-- Export de la base de données auxivie.db\n`;
    sqlContent += `-- Date: ${new Date().toISOString()}\n\n`;

    // Exporter chaque table
    for (const table of tables) {
      console.log(`\n📤 Export table: ${table}`);
      
      const schema = await getTableSchema(table);
      const rows = await exportTable(table);
      
      console.log(`   ✅ ${rows.length} lignes exportées`);

      // Générer le CREATE TABLE
      const createTable = await new Promise((resolve, reject) => {
        db.get(`SELECT sql FROM sqlite_master WHERE type='table' AND name='${table}'`, [], (err, row) => {
          if (err) return reject(err);
          resolve(row ? row.sql : '');
        });
      });

      sqlContent += `-- Table: ${table}\n`;
      sqlContent += `DROP TABLE IF EXISTS ${table};\n`;
      sqlContent += createTable + ';\n\n';

      // Générer les INSERT
      if (rows.length > 0) {
        sqlContent += generateInsertSQL(table, rows, schema);
      }
    }

    // Écrire le fichier
    fs.writeFileSync(outputPath, sqlContent, 'utf8');
    console.log(`\n✅ Export terminé: ${outputPath}`);
    console.log(`📊 Taille du fichier: ${(fs.statSync(outputPath).size / 1024).toFixed(2)} KB`);

    db.close((err) => {
      if (err) {
        console.error('❌ Erreur fermeture base de données:', err.message);
      } else {
        console.log('✅ Base de données fermée');
      }
      process.exit(0);
    });
  } catch (error) {
    console.error('❌ Erreur export:', error);
    db.close();
    process.exit(1);
  }
}

exportDatabase();

