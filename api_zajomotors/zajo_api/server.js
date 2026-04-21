const express = require("express");
const mysql = require("mysql");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

// 🔌 CONEXIÓN MYSQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "zajomotors"
});

db.connect((err) => {
  if (err) {
    console.log("Error conexión DB:", err);
  } else {
    console.log("MySQL conectado 🚀");
  }
});

// 🔐 LOGIN CON FIREBASE UID
app.post("/login", (req, res) => {
  const uid = req.body.uid;

  db.query(
    "SELECT id, nombre, email, rol FROM usuarios WHERE firebase_uid = ?",
    [uid],
    (err, result) => {
      if (err) {
        return res.status(500).json(err);
      }

      if (result.length > 0) {
        res.json({
          success: true,
          user: result[0]
        });
      } else {
        res.json({
          success: false,
          message: "Usuario no encontrado"
        });
      }
    }
  );
});

// 🚀 INICIAR SERVIDOR
app.listen(3000, () => {
  console.log("API corriendo en http://localhost:3000");
});