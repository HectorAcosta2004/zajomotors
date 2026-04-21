const express = require("express");
const mysql = require("mysql");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());
app.get("/", (req, res) => {
  res.send("API funcionando 🚀");
});

// 🔌 MYSQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "zajomotors"
});

db.connect((err) => {
  if (err) {
    console.log("Error MySQL:", err);
  } else {
    console.log("MySQL conectado 🚀");
  }
});


// 🆕 REGISTER
app.post("/register", (req, res) => {
  const { uid, nombre, email } = req.body;

  console.log("📩 DATA RECIBIDA:", req.body);

  if (!uid || !nombre || !email) {
    return res.json({
      success: false,
      error: "Faltan datos"
    });
  }

  const sql = `
    INSERT INTO usuarios (firebase_uid, nombre, email, rol)
    VALUES (?, ?, ?, 'cliente')
  `;

  db.query(sql, [uid, nombre, email], (err) => {
    if (err) {
      console.log("❌ MYSQL ERROR:", err.sqlMessage);
      return res.json({
        success: false,
        error: err.sqlMessage
      });
    }

    res.json({
      success: true,
      message: "Usuario guardado correctamente"
    });
  });
});


// 🔐 LOGIN
app.post("/login", (req, res) => {
  const uid = req.body.uid;

  db.query(
    "SELECT id, nombre, email, rol FROM usuarios WHERE firebase_uid = ?",
    [uid],
    (err, result) => {
      if (err) return res.json({ success: false });

      if (result.length > 0) {
        res.json({
          success: true,
          user: result[0]
        });
      } else {
        res.json({ success: false });
      }
    }
  );
});


// 🚀 SERVER
const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en http://0.0.0.0:${PORT}`);
});