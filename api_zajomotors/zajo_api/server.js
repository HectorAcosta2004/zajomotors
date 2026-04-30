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
        return res.json({ success: false, error: "Correo ya registrado" });
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
          res.json({ success: true, message: "Usuario creado" });
        }
      );
    }
  );
});

// ===============================
// CATALOGO (ADMIN)
// ===============================
app.post("/producto/crear", (req, res) => {
  const { nombre, descripcion, precio, stock, imagen } = req.body;
  const sql = "INSERT INTO productos (nombre, descripcion, precio, stock, imagen) VALUES (?, ?, ?, ?, ?)";
  
  db.query(sql, [nombre, descripcion, precio, stock, imagen], (err) => {
    if (err) {
      console.log(err);
      return res.json({ success: false });
    }
    res.json({ success: true, message: "Producto creado" });
  });
});

app.post("/producto/editar", (req, res) => {
  const { id, nombre, precio, stock } = req.body;
  console.log("📥 EDITAR RECIBIDO:", req.body);

  const sql = "UPDATE productos SET nombre = ?, precio = ?, stock = ? WHERE id = ?";
  db.query(sql, [nombre, precio, stock, id], (err, result) => {
    if (err) {
      console.log("❌ ERROR SQL:", err);
      return res.json({ success: false, error: err });
    }
    res.json({ success: true, message: "Producto actualizado" });
  });
});

app.post("/producto/eliminar", (req, res) => {
  const { id } = req.body;
  db.query("DELETE FROM productos WHERE id = ?", [id], (err) => {
    if (err) {
      console.log(err);
      return res.json({ success: false });
    }
    res.json({ success: true, message: "Producto eliminado" });
  });
});

// ===============================
// 🔐 LOGIN
// ===============================
app.post("/login", (req, res) => {
  const { email, password } = req.body;
  console.log("📥 Login:", req.body);

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
      user: {
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        rol: user.rol,
      },
    });
  });
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
    res.json({ success: true, productos: result });
  });
});

// ===============================
// 🛒 RUTAS DEL CARRITO
// ===============================

// 1. OBTENER EL CARRITO
app.get("/carrito/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  const sql = `
    SELECT 
      ci.id,
      p.id as producto_id,
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
    if (err) return res.json({ success: false });
    res.json({ success: true, carrito: result });
  });
});

// 2. AGREGAR AL CARRITO
app.post('/api/carrito/agregar', (req, res) => {
    const { usuario_id, producto_id, cantidad } = req.body;

    const queryBuscarCarrito = "SELECT id FROM carrito WHERE usuario_id = ?";
    db.query(queryBuscarCarrito, [usuario_id], (err, carritos) => {
        if (err) return res.status(500).json({ error: err.message });

        if (carritos.length > 0) {
            const carrito_id = carritos[0].id;
            agregarItemAlCarrito(carrito_id, producto_id, cantidad || 1, res);
        } else {
            const queryCrearCarrito = "INSERT INTO carrito (usuario_id) VALUES (?)";
            db.query(queryCrearCarrito, [usuario_id], (err, result) => {
                if (err) return res.status(500).json({ error: err.message });
                agregarItemAlCarrito(result.insertId, producto_id, cantidad || 1, res);
            });
        }
    });
});

// Función auxiliar para insertar
function agregarItemAlCarrito(carrito_id, producto_id, cantidad, res) {
    const queryBuscarItem = "SELECT id, cantidad FROM carrito_items WHERE carrito_id = ? AND producto_id = ?";
    db.query(queryBuscarItem, [carrito_id, producto_id], (err, items) => {
        if (err) return res.status(500).json({ error: err.message });

        if (items.length > 0) {
            const nuevaCantidad = items[0].cantidad + cantidad;
            const queryActualizar = "UPDATE carrito_items SET cantidad = ? WHERE id = ?";
            db.query(queryActualizar, [nuevaCantidad, items[0].id], (err) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: "Cantidad actualizada" });
            });
        } else {
            const queryInsertar = "INSERT INTO carrito_items (carrito_id, producto_id, cantidad) VALUES (?, ?, ?)";
            db.query(queryInsertar, [carrito_id, producto_id, cantidad], (err) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: "Producto agregado" });
            });
        }
    });
}

// 3. ELIMINAR DEL CARRITO (Unidad por unidad)
app.post('/api/carrito/eliminar', (req, res) => {
    const { usuario_id, producto_id } = req.body;
    
    const queryCarrito = "SELECT id FROM carrito WHERE usuario_id = ?";
    db.query(queryCarrito, [usuario_id], (err, carritos) => {
        if (err) return res.status(500).json({ error: err.message });
        if (carritos.length === 0) return res.status(404).json({ error: "Carrito no encontrado" });
        
        const carrito_id = carritos[0].id;
        
        const queryBuscarItem = "SELECT id, cantidad FROM carrito_items WHERE carrito_id = ? AND producto_id = ?";
        db.query(queryBuscarItem, [carrito_id, producto_id], (err, items) => {
            if (err) return res.status(500).json({ error: err.message });
            if (items.length === 0) return res.status(404).json({ error: "Producto no encontrado en el carrito" });

            const item = items[0];

            if (item.cantidad > 1) {
                const queryRestar = "UPDATE carrito_items SET cantidad = cantidad - 1 WHERE id = ?";
                db.query(queryRestar, [item.id], (err) => {
                    if (err) return res.status(500).json({ error: err.message });
                    res.json({ success: true, message: "Se restó una unidad del producto" });
                });
            } else {
                const queryDelete = "DELETE FROM carrito_items WHERE id = ?";
                db.query(queryDelete, [item.id], (err) => {
                    if (err) return res.status(500).json({ error: err.message });
                    res.json({ success: true, message: "Producto eliminado completamente del carrito" });
                });
            }
        });
    });
});

// ==========================================
// 4. FINALIZAR COMPRA (Versión Segura y con Diagnóstico)
// ==========================================
app.post('/api/carrito/finalizar', (req, res) => {
    const { usuario_id, total } = req.body;
    
    console.log("\n========================================");
    console.log("🛒 INTENTO DE FINALIZAR COMPRA");
    console.log("👤 Usuario ID recibido desde Flutter:", usuario_id);

    // PRIMERO buscamos los items antes de crear la orden
    const queryGetItems = `
        SELECT c.id as carrito_id, ci.producto_id, ci.cantidad, p.precio 
        FROM carrito c 
        JOIN carrito_items ci ON c.id = ci.carrito_id 
        JOIN productos p ON ci.producto_id = p.id
        WHERE c.usuario_id = ?`;

    db.query(queryGetItems, [usuario_id], (err, items) => {
        if (err) {
            console.log("❌ Error leyendo carrito en MySQL:", err);
            return res.status(500).json({ error: "Error leyendo carrito" });
        }

        console.log("📦 Items válidos encontrados en BD para este usuario:", items.length);

        if (items.length === 0) {
            // DIAGNÓSTICO: Si es 0, buscamos dónde está el problema
            db.query("SELECT id FROM carrito WHERE usuario_id = ?", [usuario_id], (err, carritos) => {
                if (carritos && carritos.length > 0) {
                    console.log("⚠️ El usuario SÍ tiene un carrito creado (ID:", carritos[0].id, "), pero no tiene productos en carrito_items.");
                } else {
                    console.log("⚠️ El usuario NO tiene ningún carrito registrado en la tabla 'carrito'.");
                }
            });
            return res.status(400).json({ error: "El carrito está vacío" });
        }

        // Si hay items, procedemos a crear la orden
        const queryOrden = "INSERT INTO orden_servicio (cliente_id, total, estado) VALUES (?, ?, 'pendiente')";
        db.query(queryOrden, [usuario_id, total], (err, resultOrden) => {
            if (err) return res.status(500).json({ error: "Error al crear orden" });
            
            const orden_id = resultOrden.insertId;

            // Pasamos los productos a detalle_orden
            const valores = items.map(item => [orden_id, item.producto_id, item.cantidad, item.precio]);
            const queryDetalle = "INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio) VALUES ?";
            
            db.query(queryDetalle, [valores], (err) => {
                if (err) return res.status(500).json({ error: "Error guardando detalle_orden" });

                // Vaciamos el carrito de forma segura usando el carrito_id
                const carritosIds = [...new Set(items.map(i => i.carrito_id))]; 
                db.query("DELETE FROM carrito_items WHERE carrito_id IN (?)", [carritosIds], (err) => {
                    if (err) return res.status(500).json({ error: "Error al vaciar carrito" });
                    
                    // Notificación
                    db.query(
                        "INSERT INTO notificaciones (usuario_id, mensaje, tipo) VALUES (?, 'Tu compra fue procesada correctamente', 'compra')",
                        [usuario_id]
                    );

                    console.log("✅ ¡COMPRA EXITOSA! Orden generada:", orden_id);
                    res.json({ success: true, message: "Compra finalizada", orden_id: orden_id });
                });
            });
        });
    });
});

// AUMENTAR Y RESTAR (Botones de la interfaz vieja por si acaso)
app.post("/carrito/sumar", (req, res) => {
  const { item_id } = req.body;
  db.query("UPDATE carrito_items SET cantidad = cantidad + 1 WHERE id = ?", [item_id], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true });
  });
});

app.post("/carrito/restar", (req, res) => {
  const { item_id } = req.body;
  db.query("UPDATE carrito_items SET cantidad = GREATEST(cantidad - 1, 1) WHERE id = ?", [item_id], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true });
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

// ===============================
// 📦 ÓRDENES E HISTORIAL
// ===============================
app.get("/ordenes/tecnico", (req, res) => {
  db.query("SELECT * FROM orden_servicio ORDER BY id DESC", (err, result) => {
    res.json({ success: true, data: result });
  });
});

app.get("/ordenes/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  db.query("SELECT * FROM orden_servicio WHERE cliente_id = ? ORDER BY id DESC", [usuarioId], (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, ordenes: result });
  });
});

// ===============================
// 🔧 CAMBIAR ESTADO ORDEN
// ===============================
app.post("/orden/estado", (req, res) => {
  const { orden_id, estado } = req.body;

  db.query("UPDATE orden_servicio SET estado = ? WHERE id = ?", [estado, orden_id], (err) => {
    if (err) return res.json({ success: false });

    // 🔔 Crear notificación automática
    db.query(
      "INSERT INTO notificaciones (usuario_id, mensaje, tipo) SELECT cliente_id, ?, 'servicio' FROM orden_servicio WHERE id = ?",
      [`Tu orden ahora está: ${estado}`, orden_id]
    );

    res.json({ success: true, message: "Estado actualizado" });
  });
});

// ===============================
// 🔔 NOTIFICACIONES
// ===============================
app.get("/notificaciones/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  db.query("SELECT * FROM notificaciones WHERE usuario_id = ? ORDER BY id DESC", [usuarioId], (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, data: result });
  });
});

// ===============================
// 🚀 SERVER
// ===============================
app.listen(3000, "0.0.0.0", () => {
  console.log("🚀 API corriendo en http://192.168.88.101:3000");
});const express = require("express");
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
        return res.json({ success: false, error: "Correo ya registrado" });
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
          res.json({ success: true, message: "Usuario creado" });
        }
      );
    }
  );
});

// ===============================
// CATALOGO (ADMIN)
// ===============================
app.post("/producto/crear", (req, res) => {
  const { nombre, descripcion, precio, stock, imagen } = req.body;
  const sql = "INSERT INTO productos (nombre, descripcion, precio, stock, imagen) VALUES (?, ?, ?, ?, ?)";
  
  db.query(sql, [nombre, descripcion, precio, stock, imagen], (err) => {
    if (err) {
      console.log(err);
      return res.json({ success: false });
    }
    res.json({ success: true, message: "Producto creado" });
  });
});

app.post("/producto/editar", (req, res) => {
  const { id, nombre, precio, stock } = req.body;
  console.log("📥 EDITAR RECIBIDO:", req.body);

  const sql = "UPDATE productos SET nombre = ?, precio = ?, stock = ? WHERE id = ?";
  db.query(sql, [nombre, precio, stock, id], (err, result) => {
    if (err) {
      console.log("❌ ERROR SQL:", err);
      return res.json({ success: false, error: err });
    }
    res.json({ success: true, message: "Producto actualizado" });
  });
});

app.post("/producto/eliminar", (req, res) => {
  const { id } = req.body;
  db.query("DELETE FROM productos WHERE id = ?", [id], (err) => {
    if (err) {
      console.log(err);
      return res.json({ success: false });
    }
    res.json({ success: true, message: "Producto eliminado" });
  });
});

// ===============================
// 🔐 LOGIN
// ===============================
app.post("/login", (req, res) => {
  const { email, password } = req.body;
  console.log("📥 Login:", req.body);

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
      user: {
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        rol: user.rol,
      },
    });
  });
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
    res.json({ success: true, productos: result });
  });
});

// ===============================
// 🛒 RUTAS DEL CARRITO
// ===============================

// 1. OBTENER EL CARRITO
app.get("/carrito/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  const sql = `
    SELECT 
      ci.id,
      p.id as producto_id,
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
    if (err) return res.json({ success: false });
    res.json({ success: true, carrito: result });
  });
});

// 2. AGREGAR AL CARRITO
app.post('/api/carrito/agregar', (req, res) => {
    const { usuario_id, producto_id, cantidad } = req.body;

    const queryBuscarCarrito = "SELECT id FROM carrito WHERE usuario_id = ?";
    db.query(queryBuscarCarrito, [usuario_id], (err, carritos) => {
        if (err) return res.status(500).json({ error: err.message });

        if (carritos.length > 0) {
            const carrito_id = carritos[0].id;
            agregarItemAlCarrito(carrito_id, producto_id, cantidad || 1, res);
        } else {
            const queryCrearCarrito = "INSERT INTO carrito (usuario_id) VALUES (?)";
            db.query(queryCrearCarrito, [usuario_id], (err, result) => {
                if (err) return res.status(500).json({ error: err.message });
                agregarItemAlCarrito(result.insertId, producto_id, cantidad || 1, res);
            });
        }
    });
});

// Función auxiliar para insertar
function agregarItemAlCarrito(carrito_id, producto_id, cantidad, res) {
    const queryBuscarItem = "SELECT id, cantidad FROM carrito_items WHERE carrito_id = ? AND producto_id = ?";
    db.query(queryBuscarItem, [carrito_id, producto_id], (err, items) => {
        if (err) return res.status(500).json({ error: err.message });

        if (items.length > 0) {
            const nuevaCantidad = items[0].cantidad + cantidad;
            const queryActualizar = "UPDATE carrito_items SET cantidad = ? WHERE id = ?";
            db.query(queryActualizar, [nuevaCantidad, items[0].id], (err) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: "Cantidad actualizada" });
            });
        } else {
            const queryInsertar = "INSERT INTO carrito_items (carrito_id, producto_id, cantidad) VALUES (?, ?, ?)";
            db.query(queryInsertar, [carrito_id, producto_id, cantidad], (err) => {
                if (err) return res.status(500).json({ error: err.message });
                res.json({ message: "Producto agregado" });
            });
        }
    });
}

// 3. ELIMINAR DEL CARRITO (Unidad por unidad)
app.post('/api/carrito/eliminar', (req, res) => {
    const { usuario_id, producto_id } = req.body;
    
    const queryCarrito = "SELECT id FROM carrito WHERE usuario_id = ?";
    db.query(queryCarrito, [usuario_id], (err, carritos) => {
        if (err) return res.status(500).json({ error: err.message });
        if (carritos.length === 0) return res.status(404).json({ error: "Carrito no encontrado" });
        
        const carrito_id = carritos[0].id;
        
        const queryBuscarItem = "SELECT id, cantidad FROM carrito_items WHERE carrito_id = ? AND producto_id = ?";
        db.query(queryBuscarItem, [carrito_id, producto_id], (err, items) => {
            if (err) return res.status(500).json({ error: err.message });
            if (items.length === 0) return res.status(404).json({ error: "Producto no encontrado en el carrito" });

            const item = items[0];

            if (item.cantidad > 1) {
                const queryRestar = "UPDATE carrito_items SET cantidad = cantidad - 1 WHERE id = ?";
                db.query(queryRestar, [item.id], (err) => {
                    if (err) return res.status(500).json({ error: err.message });
                    res.json({ success: true, message: "Se restó una unidad del producto" });
                });
            } else {
                const queryDelete = "DELETE FROM carrito_items WHERE id = ?";
                db.query(queryDelete, [item.id], (err) => {
                    if (err) return res.status(500).json({ error: err.message });
                    res.json({ success: true, message: "Producto eliminado completamente del carrito" });
                });
            }
        });
    });
});

// ==========================================
// 4. FINALIZAR COMPRA (Versión Segura y con Diagnóstico)
// ==========================================
app.post('/api/carrito/finalizar', (req, res) => {
    const { usuario_id, total } = req.body;
    
    console.log("\n========================================");
    console.log("🛒 INTENTO DE FINALIZAR COMPRA");
    console.log("👤 Usuario ID recibido desde Flutter:", usuario_id);

    // PRIMERO buscamos los items antes de crear la orden
    const queryGetItems = `
        SELECT c.id as carrito_id, ci.producto_id, ci.cantidad, p.precio 
        FROM carrito c 
        JOIN carrito_items ci ON c.id = ci.carrito_id 
        JOIN productos p ON ci.producto_id = p.id
        WHERE c.usuario_id = ?`;

    db.query(queryGetItems, [usuario_id], (err, items) => {
        if (err) {
            console.log("❌ Error leyendo carrito en MySQL:", err);
            return res.status(500).json({ error: "Error leyendo carrito" });
        }

        console.log("📦 Items válidos encontrados en BD para este usuario:", items.length);

        if (items.length === 0) {
            // DIAGNÓSTICO: Si es 0, buscamos dónde está el problema
            db.query("SELECT id FROM carrito WHERE usuario_id = ?", [usuario_id], (err, carritos) => {
                if (carritos && carritos.length > 0) {
                    console.log("⚠️ El usuario SÍ tiene un carrito creado (ID:", carritos[0].id, "), pero no tiene productos en carrito_items.");
                } else {
                    console.log("⚠️ El usuario NO tiene ningún carrito registrado en la tabla 'carrito'.");
                }
            });
            return res.status(400).json({ error: "El carrito está vacío" });
        }

        // Si hay items, procedemos a crear la orden
        const queryOrden = "INSERT INTO orden_servicio (cliente_id, total, estado) VALUES (?, ?, 'pendiente')";
        db.query(queryOrden, [usuario_id, total], (err, resultOrden) => {
            if (err) return res.status(500).json({ error: "Error al crear orden" });
            
            const orden_id = resultOrden.insertId;

            // Pasamos los productos a detalle_orden
            const valores = items.map(item => [orden_id, item.producto_id, item.cantidad, item.precio]);
            const queryDetalle = "INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio) VALUES ?";
            
            db.query(queryDetalle, [valores], (err) => {
                if (err) return res.status(500).json({ error: "Error guardando detalle_orden" });

                // Vaciamos el carrito de forma segura usando el carrito_id
                const carritosIds = [...new Set(items.map(i => i.carrito_id))]; 
                db.query("DELETE FROM carrito_items WHERE carrito_id IN (?)", [carritosIds], (err) => {
                    if (err) return res.status(500).json({ error: "Error al vaciar carrito" });
                    
                    // Notificación
                    db.query(
                        "INSERT INTO notificaciones (usuario_id, mensaje, tipo) VALUES (?, 'Tu compra fue procesada correctamente', 'compra')",
                        [usuario_id]
                    );

                    console.log("✅ ¡COMPRA EXITOSA! Orden generada:", orden_id);
                    res.json({ success: true, message: "Compra finalizada", orden_id: orden_id });
                });
            });
        });
    });
});

// AUMENTAR Y RESTAR (Botones de la interfaz vieja por si acaso)
app.post("/carrito/sumar", (req, res) => {
  const { item_id } = req.body;
  db.query("UPDATE carrito_items SET cantidad = cantidad + 1 WHERE id = ?", [item_id], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true });
  });
});

app.post("/carrito/restar", (req, res) => {
  const { item_id } = req.body;
  db.query("UPDATE carrito_items SET cantidad = GREATEST(cantidad - 1, 1) WHERE id = ?", [item_id], (err) => {
    if (err) return res.json({ success: false });
    res.json({ success: true });
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

// ===============================
// 📦 ÓRDENES E HISTORIAL
// ===============================
app.get("/ordenes/tecnico", (req, res) => {
  db.query("SELECT * FROM orden_servicio ORDER BY id DESC", (err, result) => {
    res.json({ success: true, data: result });
  });
});

app.get("/ordenes/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  db.query("SELECT * FROM orden_servicio WHERE cliente_id = ? ORDER BY id DESC", [usuarioId], (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, ordenes: result });
  });
});

// ===============================
// 🔧 CAMBIAR ESTADO ORDEN
// ===============================
app.post("/orden/estado", (req, res) => {
  const { orden_id, estado } = req.body;

  db.query("UPDATE orden_servicio SET estado = ? WHERE id = ?", [estado, orden_id], (err) => {
    if (err) return res.json({ success: false });

    // 🔔 Crear notificación automática
    db.query(
      "INSERT INTO notificaciones (usuario_id, mensaje, tipo) SELECT cliente_id, ?, 'servicio' FROM orden_servicio WHERE id = ?",
      [`Tu orden ahora está: ${estado}`, orden_id]
    );

    res.json({ success: true, message: "Estado actualizado" });
  });
});

// ===============================
// 🔔 NOTIFICACIONES
// ===============================
app.get("/notificaciones/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  db.query("SELECT * FROM notificaciones WHERE usuario_id = ? ORDER BY id DESC", [usuarioId], (err, result) => {
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