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

  if (!nombre || !email || !password) {
    return res.json({ success: false, error: "Campos vacíos" });
  }

  db.query("SELECT * FROM usuarios WHERE email = ?", [email], async (err, result) => {
      if (err) return res.json({ success: false });

      if (result.length > 0) {
        return res.json({ success: false, error: "Correo ya registrado" });
      }

      const hash = await bcrypt.hash(password, 10);

      db.query("INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, 'cliente')",
        [nombre, email, hash],
        (err) => {
          if (err) return res.json({ success: false });
          res.json({ success: true, message: "Usuario creado" });
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

  db.query("SELECT * FROM usuarios WHERE email = ?", [email], async (err, result) => {
    if (err) return res.json({ success: false });

    if (result.length === 0) {
      return res.json({ success: false, error: "Usuario no encontrado" });
    }

    const user = result[0];
    const valid = await bcrypt.compare(password, user.password);

    if (!valid) {
      return res.json({ success: false, error: "Contraseña incorrecta" });
    }

    res.json({
      success: true,
      user: { id: user.id, nombre: user.nombre, email: user.email, rol: user.rol },
    });
  });
});

// ===============================
// 📦 PRODUCTOS (Catálogo)
// ===============================
app.get("/productos", (req, res) => {
  db.query("SELECT * FROM productos", (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, productos: result });
  });
});

app.post("/producto/crear", (req, res) => {
  const { nombre, descripcion, precio, stock, imagen } = req.body;
  const sql = "INSERT INTO productos (nombre, descripcion, precio, stock, imagen) VALUES (?, ?, ?, ?, ?)";
  db.query(sql, [nombre, descripcion, precio, stock, imagen], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, message: "Producto creado" });
  });
});

app.post("/producto/editar", (req, res) => {
  const { id, nombre, precio, stock } = req.body;
  const sql = "UPDATE productos SET nombre = ?, precio = ?, stock = ? WHERE id = ?";
  db.query(sql, [nombre, precio, stock, id], (err) => {
    if (err) return res.json({ success: false, error: err });
    res.json({ success: true, message: "Producto actualizado" });
  });
});

app.post("/producto/eliminar", (req, res) => {
  const { id } = req.body;
  db.query("DELETE FROM productos WHERE id = ?", [id], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, message: "Producto eliminado" });
  });
});

// ===============================
// 🛠️ SERVICIOS (Nuevo)
// ===============================
app.get("/servicios", (req, res) => {
  db.query("SELECT * FROM servicios", (err, result) => {
    if (err) return res.json({ success: false, error: err.message });
    res.json({ success: true, servicios: result });
  });
});

app.post("/api/servicios/agendar", (req, res) => {
  const { cliente_id, servicio_id, precio } = req.body;

  db.query("SELECT id FROM usuarios WHERE rol = 'tecnico' LIMIT 1", (err, techs) => {
    if (err) return res.status(500).json({ error: "Error buscando técnico" });
    
    const tecnico_id = techs.length > 0 ? techs[0].id : null;

    const queryOrden = "INSERT INTO orden_servicio (cliente_id, tecnico_id, total, estado) VALUES (?, ?, ?, 'pendiente')";
    db.query(queryOrden, [cliente_id, tecnico_id, precio], (err, resultOrden) => {
        if (err) return res.status(500).json({ error: "Error al crear orden" });
        const orden_id = resultOrden.insertId;

        const queryDetalle = "INSERT INTO detalle_servicio (orden_id, servicio_id, precio) VALUES (?, ?, ?)";
        db.query(queryDetalle, [orden_id, servicio_id, precio], (err) => {
            if (err) return res.status(500).json({ error: "Error en detalle" });

            if (tecnico_id) {
                db.query(
                    "INSERT INTO notificaciones (usuario_id, mensaje, tipo) VALUES (?, '¡Nuevo trabajo! Tienes un servicio agendado por un cliente', 'servicio')",
                    [tecnico_id]
                );
            }
            res.json({ success: true, message: "Servicio agendado con éxito", orden_id: orden_id });
        });
    });
  });
});

// ===============================
// 🛒 CARRITO
// ===============================
app.get("/carrito/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  const sql = `
    SELECT ci.id, p.id as producto_id, p.nombre, p.precio, ci.cantidad, (p.precio * ci.cantidad) as total
    FROM carrito c
    JOIN carrito_items ci ON c.id = ci.carrito_id
    JOIN productos p ON ci.producto_id = p.id
    WHERE c.usuario_id = ?
  `;
  db.query(sql, [usuarioId], (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, carrito: result });
  });
});

app.post('/api/carrito/agregar', (req, res) => {
    const { usuario_id, producto_id, cantidad } = req.body;
    const queryBuscarCarrito = "SELECT id FROM carrito WHERE usuario_id = ?";
    db.query(queryBuscarCarrito, [usuario_id], (err, carritos) => {
        if (err) return res.status(500).json({ error: err.message });

        if (carritos.length > 0) {
            agregarItemAlCarrito(carritos[0].id, producto_id, cantidad || 1, res);
        } else {
            db.query("INSERT INTO carrito (usuario_id) VALUES (?)", [usuario_id], (err, result) => {
                if (err) return res.status(500).json({ error: err.message });
                agregarItemAlCarrito(result.insertId, producto_id, cantidad || 1, res);
            });
        }
    });
});

function agregarItemAlCarrito(carrito_id, producto_id, cantidad, res) {
    const queryBuscarItem = "SELECT id, cantidad FROM carrito_items WHERE carrito_id = ? AND producto_id = ?";
    db.query(queryBuscarItem, [carrito_id, producto_id], (err, items) => {
        if (err) return res.status(500).json({ error: err.message });

        if (items.length > 0) {
            const nuevaCantidad = items[0].cantidad + cantidad;
            db.query("UPDATE carrito_items SET cantidad = ? WHERE id = ?", [nuevaCantidad, items[0].id], (err) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: "Cantidad actualizada" });
            });
        } else {
            db.query("INSERT INTO carrito_items (carrito_id, producto_id, cantidad) VALUES (?, ?, ?)", [carrito_id, producto_id, cantidad], (err) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: "Producto agregado" });
            });
        }
    });
}

app.post('/api/carrito/eliminar', (req, res) => {
    const { usuario_id, producto_id } = req.body;
    db.query("SELECT id FROM carrito WHERE usuario_id = ?", [usuario_id], (err, carritos) => {
        if (err) return res.status(500).json({ error: err.message });
        if (carritos.length === 0) return res.status(404).json({ error: "Carrito no encontrado" });
        
        db.query("SELECT id, cantidad FROM carrito_items WHERE carrito_id = ? AND producto_id = ?", [carritos[0].id, producto_id], (err, items) => {
            if (err) return res.status(500).json({ error: err.message });
            if (items.length === 0) return res.status(404).json({ error: "Producto no encontrado en el carrito" });

            if (items[0].cantidad > 1) {
                db.query("UPDATE carrito_items SET cantidad = cantidad - 1 WHERE id = ?", [items[0].id], (err) => {
                    if (err) return res.status(500).json({ error: err.message });
                    res.json({ success: true, message: "Se restó una unidad del producto" });
                });
            } else {
                db.query("DELETE FROM carrito_items WHERE id = ?", [items[0].id], (err) => {
                    if (err) return res.status(500).json({ error: err.message });
                    res.json({ success: true, message: "Producto eliminado completamente del carrito" });
                });
            }
        });
    });
});

app.post('/api/carrito/finalizar', (req, res) => {
    const { usuario_id, total } = req.body;
    
    const queryGetItems = `
        SELECT c.id as carrito_id, ci.producto_id, ci.cantidad, p.precio 
        FROM carrito c 
        JOIN carrito_items ci ON c.id = ci.carrito_id 
        JOIN productos p ON ci.producto_id = p.id
        WHERE c.usuario_id = ?`;

    db.query(queryGetItems, [usuario_id], (err, items) => {
        if (err) return res.status(500).json({ error: "Error leyendo carrito" });
        if (items.length === 0) return res.status(400).json({ error: "El carrito está vacío" });

        db.query("INSERT INTO orden_servicio (cliente_id, total, estado) VALUES (?, ?, 'pendiente')", [usuario_id, total], (err, resultOrden) => {
            if (err) return res.status(500).json({ error: "Error al crear orden" });
            const orden_id = resultOrden.insertId;

            const valores = items.map(item => [orden_id, item.producto_id, item.cantidad, item.precio]);
            db.query("INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio) VALUES ?", [valores], (err) => {
                if (err) return res.status(500).json({ error: "Error guardando detalle_orden" });

                const carritosIds = [...new Set(items.map(i => i.carrito_id))]; 
                db.query("DELETE FROM carrito_items WHERE carrito_id IN (?)", [carritosIds], (err) => {
                    if (err) return res.status(500).json({ error: "Error al vaciar carrito" });
                    
                    db.query("INSERT INTO notificaciones (usuario_id, mensaje, tipo) VALUES (?, 'Tu compra fue procesada correctamente', 'compra')", [usuario_id]);
                    res.json({ success: true, message: "Compra finalizada", orden_id: orden_id });
                });
            });
        });
    });
});

app.post("/carrito/sumar", (req, res) => {
  db.query("UPDATE carrito_items SET cantidad = cantidad + 1 WHERE id = ?", [req.body.item_id], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true });
  });
});

app.post("/carrito/restar", (req, res) => {
  db.query("UPDATE carrito_items SET cantidad = GREATEST(cantidad - 1, 1) WHERE id = ?", [req.body.item_id], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true });
  });
});

// ===============================
// 📄 DETALLE ORDEN (MEJORADO: Productos + Servicios)
// ===============================
app.get("/orden/detalle/:id", (req, res) => {
  const id = req.params.id;

  // Esta consulta busca en ambas tablas y junta los resultados
  const sql = `
    SELECT p.nombre, d.cantidad, d.precio
    FROM detalle_orden d
    JOIN productos p ON d.producto_id = p.id
    WHERE d.orden_id = ?
    
    UNION ALL
    
    SELECT s.nombre, 1 as cantidad, ds.precio
    FROM detalle_servicio ds
    JOIN servicios s ON ds.servicio_id = s.id
    WHERE ds.orden_id = ?
  `;

  db.query(sql, [id, id], (err, result) => {
    if (err) {
      console.log("❌ Error al obtener detalle:", err);
      return res.json({ success: false });
    }
    res.json({ success: true, detalle: result });
  });
});
app.get("/ordenes/tecnico", (req, res) => {
  db.query("SELECT * FROM orden_servicio ORDER BY id DESC", (err, result) => {
    res.json({ success: true, data: result });
  });
});

app.get("/ordenes/:usuario_id", (req, res) => {
  db.query("SELECT * FROM orden_servicio WHERE cliente_id = ? ORDER BY id DESC", [req.params.usuario_id], (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, ordenes: result });
  });
});

app.post("/orden/estado", (req, res) => {
  const { orden_id, estado } = req.body;
  db.query("UPDATE orden_servicio SET estado = ? WHERE id = ?", [estado, orden_id], (err) => {
    if (err) return res.json({ success: false });
    db.query("INSERT INTO notificaciones (usuario_id, mensaje, tipo) SELECT cliente_id, ?, 'servicio' FROM orden_servicio WHERE id = ?", [`Tu orden ahora está: ${estado}`, orden_id]);
    res.json({ success: true, message: "Estado actualizado" });
  });
});

// ===============================
// 🔔 NOTIFICACIONES
// ===============================
app.get("/notificaciones/:usuario_id", (req, res) => {
  db.query("SELECT * FROM notificaciones WHERE usuario_id = ? ORDER BY id DESC", [req.params.usuario_id], (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, data: result });
  });
});

// ===============================
// 🚀 SERVER
// ===============================
app.listen(3000, "0.0.0.0", () => {
  console.log("🚀 API corriendo en http://192.168.88.101:3000");
});