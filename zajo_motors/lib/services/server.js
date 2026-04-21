const express = require("express");
const mysql = require("mysql");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// CONEXION MYSQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "zajomotors"
});

// LOGIN POR UID FIREBASE
app.post("/login", (req, res) => {
  const uid = req.body.uid;

  db.query(
    "SELECT * FROM usuarios WHERE firebase_uid = ?",
    [uid],
    (err, result) => {
      if (err) return res.json(err);

      if (result.length > 0) {
        res.json(result[0]);
      } else {
        res.json({ error: "Usuario no encontrado" });
      }
    }
  );
});

app.listen(3000, () => {
  console.log("API corriendo en puerto 3000");
});