const express = require("express");
const mysql = require("mysql");
const cors = require("cors");
const bcrypt = require("bcrypt");

const app = express();

app.use(cors());
app.use(express.json());

// 🔌 MYSQL
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

  console.log("📥 Registro:", req.body);

  if (!nombre || !email || !password) {
    return res.json({ success: false, error: "Campos vacíos" });
  }

  db.query(
    "SELECT * FROM usuarios WHERE email = ?",
    [email],
    async (err, result) => {
      if (err) return res.json({ success: false });

      if (result.length > 0) {
        return res.json({
          success: false,
          error: "Correo ya registrado",
        });
      }

      const hash = await bcrypt.hash(password, 10);

      db.query(
        "INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, 'cliente')",
        [nombre, email, hash],
        (err) => {
          if (err) {
            console.log(err);
            return res.json({ success: false });
          }

          res.json({
            success: true,
            message: "Usuario creado",
          });
        }
      );
    }
  );
});
// ===============================
// 🔐 LOGIN
// ===============================
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  console.log("📥 Login:", req.body);

  db.query(
    "SELECT * FROM usuarios WHERE email = ?",
    [email],
    async (err, result) => {
      if (err) return res.json({ success: false });

      if (result.length === 0) {
        return res.json({
          success: false,
          error: "Usuario no encontrado",
        });
      }

      const user = result[0];

      const valid = await bcrypt.compare(password, user.password);

      if (!valid) {
        return res.json({
          success: false,
          error: "Contraseña incorrecta",
        });
      }

      res.json({
        success: true,
        user: {
          id: user.id,
          nombre: user.nombre,
          email: user.email,
          rol: user.rol,
        },
      });
    }
  );
});


// ===============================
// 📦 PRODUCTOS
// ===============================
app.get("/productos", (req, res) => {
  db.query("SELECT * FROM productos", (err, result) => {
    if (err) {
      console.log(err);
      return res.json({ success: false });
    }

    res.json({
      success: true,
      productos: result,
    });
  });
});


// ===============================
// 🛒 CARRITO
// ===============================
app.post("/carrito/agregar", (req, res) => {
  const { usuario_id, producto_id } = req.body;

  // 🔍 Buscar carrito del usuario
  db.query(
    "SELECT * FROM carrito WHERE usuario_id = ?",
    [usuario_id],
    (err, result) => {
      if (err) return res.json({ success: false });

      if (result.length > 0) {
        const carritoId = result[0].id;

        insertarItem(carritoId);
      } else {
        // crear carrito
        db.query(
          "INSERT INTO carrito (usuario_id) VALUES (?)",
          [usuario_id],
          (err2, result2) => {
            if (err2) return res.json({ success: false });

            insertarItem(result2.insertId);
          }
        );
      }

      function insertarItem(carritoId) {
        db.query(
          "INSERT INTO carrito_items (carrito_id, producto_id, cantidad) VALUES (?, ?, 1)",
          [carritoId, producto_id],
          (err3) => {
            if (err3) return res.json({ success: false });

            res.json({
              success: true,
              message: "Producto agregado",
            });
          }
        );
      }
    }
  );
});
// ===============================
// 🛒 VER CARRITO
// ===============================
app.get("/carrito/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;

  const sql = `
    SELECT 
      ci.id,
      p.nombre,
      p.precio,
      ci.cantidad,
      (p.precio * ci.cantidad) as total
    FROM carrito c
    JOIN carrito_items ci ON c.id = ci.carrito_id
    JOIN productos p ON ci.producto_id = p.id
    WHERE c.usuario_id = ?
  `;

  db.query(sql, [usuarioId], (err, result) => {
    if (err) {
      console.log(err);
      return res.json({ success: false });
    }

    res.json({
      success: true,
      carrito: result,
    });
  });
});
// ===============================
// ❌ ELIMINAR PRODUCTO
// ===============================
app.post("/carrito/eliminar", (req, res) => {
  const { item_id } = req.body;

  db.query(
    "DELETE FROM carrito_items WHERE id = ?",
    [item_id],
    (err) => {
      if (err) return res.json({ success: false });

      res.json({ success: true });
    }
  );
});
// ===============================
// ➕ AUMENTAR
// ===============================
app.post("/carrito/sumar", (req, res) => {
  const { item_id } = req.body;

  db.query(
    "UPDATE carrito_items SET cantidad = cantidad + 1 WHERE id = ?",
    [item_id],
    (err) => {
      if (err) return res.json({ success: false });

      res.json({ success: true });
    }
  );
});
// ===============================
// ➖ RESTAR
// ===============================
app.post("/carrito/restar", (req, res) => {
  const { item_id } = req.body;

  db.query(
    "UPDATE carrito_items SET cantidad = GREATEST(cantidad - 1, 1) WHERE id = ?",
    [item_id],
    (err) => {
      if (err) return res.json({ success: false });

      res.json({ success: true });
    }
  );
});
// ===============================
// 💳 CHECKOUT
// ===============================
app.post("/checkout", (req, res) => {
  const { usuario_id } = req.body;

  // 1. Obtener carrito con productos
  const sqlCarrito = `
    SELECT 
      c.id as carrito_id,
      ci.producto_id,
      ci.cantidad,
      p.precio
    FROM carrito c
    JOIN carrito_items ci ON c.id = ci.carrito_id
    JOIN productos p ON ci.producto_id = p.id
    WHERE c.usuario_id = ?
  `;

  db.query(sqlCarrito, [usuario_id], (err, items) => {
    if (err) {
      console.log(err);
      return res.json({ success: false });
    }

    if (items.length === 0) {
      return res.json({
        success: false,
        error: "Carrito vacío",
      });
    }

    // 2. Calcular total
    let total = 0;
    items.forEach((i) => {
      total += i.precio * i.cantidad;
    });

    // 3. Crear orden
    const sqlOrden = `
      INSERT INTO orden_servicio (cliente_id, estado, total)
      VALUES (?, 'pendiente', ?)
    `;

    db.query(sqlOrden, [usuario_id, total], (err2, resultOrden) => {
      if (err2) {
        console.log(err2);
        return res.json({ success: false });
      }

      const ordenId = resultOrden.insertId;

      // 4. Insertar detalle
      const values = items.map((i) => [
        ordenId,
        i.producto_id,
        i.cantidad,
        i.precio,
      ]);

      const sqlDetalle = `
        INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio)
        VALUES ?
      `;

      db.query(sqlDetalle, [values], (err3) => {
        if (err3) {
          console.log(err3);
          return res.json({ success: false });
        }

        // 5. Vaciar carrito
        const carritoId = items[0].carrito_id;

        db.query(
          "DELETE FROM carrito_items WHERE carrito_id = ?",
          [carritoId],
          (err4) => {
            if (err4) {
              console.log(err4);
              return res.json({ success: false });
            }

            // 6. Notificación (opcional)
            db.query(
              "INSERT INTO notificaciones (usuario_id, mensaje, tipo) VALUES (?, ?, 'compra')",
              [usuario_id, "Tu compra fue realizada correctamente"],
              () => {}
            );

            res.json({
              success: true,
              message: "Compra realizada",
              orden_id: ordenId,
            });
          }
        );
      });
    });
  });
});
// ===============================
// 📄 DETALLE ORDEN
// ===============================
app.get("/orden/detalle/:id", (req, res) => {
  const id = req.params.id;

  const sql = `
    SELECT p.nombre, d.cantidad, d.precio
    FROM detalle_orden d
    JOIN productos p ON d.producto_id = p.id
    WHERE d.orden_id = ?
  `;

  db.query(sql, [id], (err, result) => {
    if (err) return res.json({ success: false });

    res.json({ success: true, detalle: result });
  });
});
app.get("/notificaciones/:usuario_id", (req, res) => {
  db.query(
    "SELECT * FROM notificaciones WHERE usuario_id = ? ORDER BY id DESC",
    [req.params.usuario_id],
    (err, result) => {
      res.json({ success: true, data: result });
    }
  );
});
app.get("/ordenes/tecnico", (req, res) => {
  db.query(
    "SELECT * FROM orden_servicio ORDER BY id DESC",
    (err, result) => {
      res.json({ success: true, data: result });
    }
  );
});
// ===============================
// 📦 HISTORIAL
// ===============================
app.get("/ordenes/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;

  db.query(
    "SELECT * FROM orden_servicio WHERE cliente_id = ? ORDER BY id DESC",
    [usuarioId],
    (err, result) => {
      if (err) return res.json({ success: false });

      res.json({
        success: true,
        ordenes: result,
      });
    }
  );
});


// 🔔 NOTIFICACIONES
app.get("/notificaciones/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;

  db.query(
    "SELECT * FROM notificaciones WHERE usuario_id = ? ORDER BY id DESC",
    [usuarioId],
    (err, result) => {
      if (err) {
        console.log(err);
        return res.json({ success: false });
      }

      res.json({
        success: true,
        data: result,
      });
    }
  );
});
// ===============================
// 🔧 CAMBIAR ESTADO ORDEN
// ===============================
app.post("/orden/estado", (req, res) => {
  const { orden_id, estado } = req.body;

  db.query(
    "UPDATE orden_servicio SET estado = ? WHERE id = ?",
    [estado, orden_id],
    (err) => {
      if (err) return res.json({ success: false });

      // 🔔 Crear notificación automática
      db.query(
        "INSERT INTO notificaciones (usuario_id, mensaje, tipo) SELECT cliente_id, ?, 'servicio' FROM orden_servicio WHERE id = ?",
        [`Tu orden ahora está: ${estado}`, orden_id]
      );

      res.json({
        success: true,
        message: "Estado actualizado",
      });
    }
  );
});
// ===============================
// 🚀 SERVER
// ===============================
app.listen(3000, "0.0.0.0", () => {
  console.log("🚀 API corriendo en http://192.168.88.105:3000");
});