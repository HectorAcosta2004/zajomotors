const express = require("express");
const mysql = require("mysql");
const cors = require("cors");
const bcrypt = require("bcrypt");

const app = express();

app.use(cors());
app.use(express.json());

// 🔌 CONEXIÓN MYSQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "zajomotors",
});

db.connect((err) => {
  if (err) {
    console.log("❌ Error MySQL:", err);
  } else {
    console.log("✅ MySQL conectado");
  }
});


// ===============================
// 🆕 REGISTER
// ===============================
app.post("/register", (req, res) => {
  const { nombre, email, password } = req.body;

  console.log("📥 Registro recibido:", req.body);

  // VALIDAR CAMPOS
  if (!nombre || !email || !password) {
    return res.json({
      success: false,
      error: "Todos los campos son obligatorios",
    });
  }

  // 🔍 VERIFICAR SI YA EXISTE
  db.query(
    "SELECT * FROM usuarios WHERE email = ?",
    [email],
    async (err, result) => {
      if (err) {
        console.log("❌ Error consulta:", err);
        return res.json({ success: false, error: "Error servidor" });
      }

      if (result.length > 0) {
        return res.json({
          success: false,
          error: "El correo ya está registrado",
        });
      }

      try {
        // 🔐 ENCRIPTAR PASSWORD
        const hashedPassword = await bcrypt.hash(password, 10);

        // 💾 INSERTAR USUARIO
        const sql = `
          INSERT INTO usuarios (nombre, email, password, rol)
          VALUES (?, ?, ?, 'cliente')
        `;

        db.query(
          sql,
          [nombre, email, hashedPassword],
          (err, result) => {
            if (err) {
              console.log("❌ Error insert:", err);
              return res.json({
                success: false,
                error: err.sqlMessage,
              });
            }

            res.json({
              success: true,
              message: "Usuario registrado correctamente",
            });
          }
        );
      } catch (error) {
        console.log("❌ Error bcrypt:", error);
        res.json({ success: false, error: "Error encriptando password" });
      }
    }
  );
});


// ===============================
// 🔐 LOGIN
// ===============================
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  console.log("📥 Login recibido:", req.body);

  if (!email || !password) {
    return res.json({
      success: false,
      error: "Email y password requeridos",
    });
  }

  // 🔍 BUSCAR USUARIO
  db.query(
    "SELECT * FROM usuarios WHERE email = ?",
    [email],
    async (err, result) => {
      if (err) {
        console.log("❌ Error consulta:", err);
        return res.json({ success: false });
      }

      if (result.length === 0) {
        return res.json({
          success: false,
          error: "Usuario no encontrado",
        });
      }

      const user = result[0];

      try {
        // 🔐 COMPARAR PASSWORD
        const validPassword = await bcrypt.compare(
          password,
          user.password
        );

        if (!validPassword) {
          return res.json({
            success: false,
            error: "Contraseña incorrecta",
          });
        }

        // ✅ LOGIN OK
        res.json({
          success: true,
          user: {
            id: user.id,
            nombre: user.nombre,
            email: user.email,
            rol: user.rol,
          },
        });
      } catch (error) {
        console.log("❌ Error bcrypt:", error);
        res.json({ success: false });
      }
    }
  );
});


// ===============================
// 🚀 SERVER
// ===============================
app.listen(3000, () => {
  console.log("🚀 API corriendo en http://localhost:3000");
});