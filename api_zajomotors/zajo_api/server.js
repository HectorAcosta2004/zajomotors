const express = require("express");
const mysql = require("mysql");
const cors = require("cors");
const bcrypt = require("bcrypt");
const axios = require("axios");

const app = express();

app.use(cors());
app.use(express.json());
// Configuración de OneSignal
const ONESIGNAL_REST_API_KEY = "os_v2_app_6ynqf4eufnfyzfjyprr5anvtvsoqvjzzj5regc47gshn6aubzmrkjsesyvj4dzar6kelqoivsdemlu6zk62etbpmddpujflvr2c2buq"; // <--- CAMBIA ESTO
const ONESIGNAL_APP_ID = "f61b02f0-942b-4b8c-9538-7c63d036b3ac";

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
// 🔔 ENDPOINT DE NOTIFICACIONES (OneSignal)
// ===============================
app.post('/api/enviar-notificacion', async (req, res) => {
  // Asegúrate de que aquí diga 'title' y 'body'
  const { title, body } = req.body; 
  
  console.log("Recibido:", title, body); 

  try {
    const response = await axios.post(
      'https://onesignal.com/api/v1/notifications',
      {
        app_id: ONESIGNAL_APP_ID,
        headings: { "en": title }, // Aquí asignas el valor
        contents: { "en": body },   // Aquí asignas el valor
        included_segments: ["All"],
      },
      {
        headers: {
          "Authorization": `Basic ${ONESIGNAL_REST_API_KEY}`,
          "Content-Type": "application/json"
        }
      }
    );
    res.status(200).json({ success: true, data: response.data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
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
// 📦 HISTORIAL DE ÓRDENES
// ===============================
app.get("/ordenes/:usuario_id", (req, res) => {
  const usuarioId = req.params.usuario_id;
  db.query("SELECT * FROM orden_servicio WHERE cliente_id = ? ORDER BY id DESC", [usuarioId], (err, result) => {
    if (err) return res.json({ success: false });
    res.json({ success: true, ordenes: result });
  });
});
// ===============================
// 👥 GESTIÓN DE USUARIOS (ADMIN)
// ===============================

// 1. Obtener todos los usuarios
app.get("/usuarios", (req, res) => {
  db.query("SELECT id, nombre, email, rol FROM usuarios", (err, result) => {
    if (err) return res.json({ success: false, error: err.message });
    res.json({ success: true, usuarios: result });
  });
});

// 2. Editar usuario
app.post("/usuario/editar", (req, res) => {
  const { id, nombre, email, rol } = req.body;
  const sql = "UPDATE usuarios SET nombre = ?, email = ?, rol = ? WHERE id = ?";
  
  db.query(sql, [nombre, email, rol, id], (err) => {
    if (err) return res.json({ success: false, error: err.message });
    res.json({ success: true, message: "Usuario actualizado correctamente" });
  });
});

// 3. Eliminar usuario
app.post("/usuario/eliminar", (req, res) => {
  const { id } = req.body;
  db.query("DELETE FROM usuarios WHERE id = ?", [id], (err) => {
    if (err) return res.json({ success: false, error: err.message });
    res.json({ success: true, message: "Usuario eliminado" });
  });
});
// 4. Cambiar contraseña de un usuario (ADMIN)
app.post("/usuario/password", async (req, res) => {
  const { id, password } = req.body;
  
  try {
    // Encriptamos la nueva contraseña antes de guardarla
    const hash = await bcrypt.hash(password, 10);
    const sql = "UPDATE usuarios SET password = ? WHERE id = ?";
    
    db.query(sql, [hash, id], (err) => {
      if (err) return res.json({ success: false, error: err.message });
      res.json({ success: true, message: "Contraseña actualizada" });
    });
  } catch (error) {
    res.json({ success: false, error: error.message });
  }
});

// ===============================
// 📋 OBTENER TODAS LAS ÓRDENES (ADMIN)
// ===============================
app.get("/admin/todas-las-ordenes", (req, res) => {
  const sql = `
    SELECT o.*, u.nombre as cliente_nombre 
    FROM orden_servicio o 
    LEFT JOIN usuarios u ON o.cliente_id = u.id 
    ORDER BY o.id DESC
  `;
  
  db.query(sql, (err, result) => {
    if (err) return res.json({ success: false, error: err.message });
    res.json({ success: true, data: result });
  });
});
// ===============================
// 🔄 CAMBIAR ESTADO DE LA ORDEN (Y NOTIFICAR)
// ===============================
app.post("/orden/estado", (req, res) => {
  const { orden_id, estado } = req.body;

  // 1. Actualizamos el estado en la tabla de órdenes
  const sqlUpdate = "UPDATE orden_servicio SET estado = ? WHERE id = ?";
  
  db.query(sqlUpdate, [estado, orden_id], (err, result) => {
    if (err) {
      console.log("❌ Error al cambiar estado:", err.message);
      return res.json({ success: false, error: err.message });
    }

    // (Opcional pero recomendado) Aquí podríamos insertar una notificación para el cliente
    console.log(`✅ Orden #${orden_id} actualizada a: ${estado}`);
    
    // Le decimos a Flutter que todo salió perfecto
    res.json({ success: true, message: "Estado actualizado correctamente" });
  });
});
// ===============================
// 📍 GESTIÓN DE SUCURSALES
// ===============================

// 1. Obtener todas las sucursales (Para Clientes y Admin)
app.get("/sucursales", (req, res) => {
  db.query("SELECT * FROM sucursales", (err, result) => {
    if (err) return res.json({ success: false, error: err.message });
    res.json({ success: true, sucursales: result });
  });
});

// 2. Crear nueva sucursal (Solo Admin)
app.post("/api/sucursales/crear", (req, res) => {
  const { nombre, direccion, telefono, imagen } = req.body;
  const sql = "INSERT INTO sucursales (nombre, direccion, telefono, imagen) VALUES (?, ?, ?, ?)";
  db.query(sql, [nombre, direccion, telefono, imagen || 'img/sucursal_default.jpg'], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true, message: "Sucursal agregada con éxito" });
  });
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
// 📄 DETALLE ORDEN (Consultas Divididas)
// ===============================
app.get("/orden/detalle/:id", (req, res) => {
  const id = req.params.id;

  // 1. Consulta solo para PRODUCTOS
  const sqlProductos = `
    SELECT p.nombre, d.cantidad, d.precio
    FROM detalle_orden d
    JOIN productos p ON d.producto_id = p.id
    WHERE d.orden_id = ?
  `;

  // 2. Consulta solo para SERVICIOS
  const sqlServicios = `
    SELECT s.nombre, 1 as cantidad, ds.precio
    FROM detalle_servicio ds
    JOIN servicios s ON ds.servicio_id = s.id
    WHERE ds.orden_id = ?
  `;

  // Primero buscamos los productos
  db.query(sqlProductos, [id], (err1, productos) => {
    if (err1) return res.json({ success: false, error: "Error en productos" });

    // Luego buscamos los servicios
    db.query(sqlServicios, [id], (err2, servicios) => {
      if (err2) return res.json({ success: false, error: "Error en servicios" });

      // Juntamos ambas listas de forma segura (si una está vacía, no afecta a la otra)
      const listaProductos = productos || [];
      const listaServicios = servicios || [];
      const detalleFinal = [...listaProductos, ...listaServicios];

      res.json({ 
        success: true, 
        detalle: detalleFinal 
      });
    });
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
// 🔐 RECUPERAR CONTRASEÑA (CLIENTE)
// ===============================
app.post("/usuario/recuperar-password", async (req, res) => {
  const { email, nueva_password } = req.body;
  
  try {
    // 1. Verificamos si el correo existe
    db.query("SELECT * FROM usuarios WHERE email = ?", [email], async (err, result) => {
      if (err) return res.json({ success: false, error: err.message });
      
      // Si el arreglo está vacío, el correo no existe
      if (result.length === 0) {
        return res.json({ success: false, message: "Este correo no está registrado" });
      }

      // 2. Si existe, encriptamos la nueva contraseña y la guardamos
      const hash = await bcrypt.hash(nueva_password, 10);
      db.query("UPDATE usuarios SET password = ? WHERE email = ?", [hash, email], (err2) => {
        if (err2) return res.json({ success: false, error: err2.message });
        res.json({ success: true, message: "Contraseña actualizada correctamente" });
      });
    });
  } catch (error) {
    res.json({ success: false, error: error.message });
  }
});
// Asegúrate de inicializar Firebase con tu serviceAccountKey.json

// Nuevo endpoint para enviar notificaciones
app.post('/api/send-notification', async (req, res) => {
  const { title, body } = req.body;

  const message = {
    notification: { title, body },
    topic: 'all_users' // Asegúrate de suscribir a los clientes a este tópico al iniciar la app
  };

  try {
    res.status(200).json({ message: "Notificación enviada con éxito" });
  } catch (error) {
    res.status(500).json({ error: "Error al enviar notificación", details: error });
  }
});
// ===============================
// 🚀 SERVER
// ===============================
app.listen(3000, "0.0.0.0", () => {
  console.log("🚀 API corriendo en http://192.168.88.138:3000");
});