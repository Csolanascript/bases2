import com.db4o.Db4oEmbedded;
import com.db4o.ObjectContainer;
import com.db4o.query.Query;
import java.util.Date;
import java.util.List;

public class Db4oPersistenceDemo {

    public static void main(String[] args) {
        ObjectContainer db = Db4oEmbedded.openFile("banco.db4o");

        try {
            // --- Inserciones Iniciales ---
            // Creación de objetos básicos
            Model.SucursalUDT sucursal = new Model.SucursalUDT(101, "Calle Central 123", "987654321");
            Model.ClienteUDT cliente = new Model.ClienteUDT("Juan", "Perez", 35, "555-1234", "juan@mail.com", "Calle Falsa 123", "12345678A");

            Model.CuentaAhorroUDT cuentaAhorro = new Model.CuentaAhorroUDT("1111", "ES001111", 1500.0, new Date(), 1.2);
            Model.CuentaCorrienteUDT cuentaCorriente = new Model.CuentaCorrienteUDT("2222", "ES002222", 2500.0, new Date(), 500.0, sucursal);

            // Relaciones directas
            cliente.getCuentas().add(cuentaAhorro);
            cliente.getCuentas().add(cuentaCorriente);

            cuentaAhorro.clientes.add(cliente);
            cuentaCorriente.clientes.add(cliente);

            // Operaciones bancarias iniciales
            Model.IngresoUDT ingreso = new Model.IngresoUDT(1, new Date(), 300.0, "Depósito inicial", cuentaAhorro, sucursal);
            Model.RetiradaUDT retirada = new Model.RetiradaUDT(2, new Date(), 100.0, "Retiro cajero", cuentaCorriente, sucursal);
            Model.TransferenciaUDT transferencia = new Model.TransferenciaUDT(3, new Date(), 200.0, "Transferencia interna", cuentaCorriente, cuentaAhorro);

            // Vincular operaciones a cuentas
            cuentaAhorro.getOperaciones().add(ingreso);
            cuentaCorriente.getOperaciones().add(retirada);
            cuentaCorriente.getOperaciones().add(transferencia);

            // Almacenar objetos iniciales en Db4o
            db.store(sucursal);
            db.store(cliente);
            db.store(cuentaAhorro);
            db.store(cuentaCorriente);

            db.commit();

            // --- Consultas Iniciales ---
            // Consulta 1: Obtener todos los clientes
            System.out.println("--- Clientes Iniciales ---");
            List<Model.ClienteUDT> clientes = db.query(Model.ClienteUDT.class);
            for (Model.ClienteUDT c : clientes) {
                System.out.println(c);
            }

            // Consulta 2: Recuperar todas las cuentas (Ahorro y Corriente)
            List<Model.CuentaUDT> todasLasCuentas = db.query(Model.CuentaUDT.class);
            System.out.println("--- Todas las Cuentas Iniciales ---");
            for (Model.CuentaUDT cuenta : todasLasCuentas) {
                System.out.println(cuenta);
            }

            // Consulta 3: Operaciones con monto mayor a 150
            System.out.println("--- Operaciones con monto mayor a 150 ---");
            Query q = db.query();
            q.constrain(Model.OperacionBancariaUDT.class);
            q.descend("cantidad").constrain(150.0).greater();
            List<Model.OperacionBancariaUDT> operaciones = q.execute();
            for (Model.OperacionBancariaUDT op : operaciones) {
                System.out.println("Operación: " + op.descripcion + ", monto: " + op.cantidad);
            }

            // --- Inserciones Adicionales ---
            System.out.println("--- Insertando datos adicionales ---");
            // Insertar 5 clientes adicionales con sus cuentas
            for (int i = 6; i <= 10; i++) {
                Model.ClienteUDT cli = new Model.ClienteUDT("Cliente" + i, "Apellido" + i, 20 + i, "555-000" + i,
                        "cliente" + i + "@mail.com", "Dirección " + i, "DNI" + i);
                // Para cada cliente, crear una cuenta de ahorro
                Model.CuentaAhorroUDT ca = new Model.CuentaAhorroUDT("CA" + i, "ESAHO" + i, 1000.0 * i, new Date(), 1.5);
                cli.getCuentas().add(ca);
                ca.clientes.add(cli);

                // Además, crear una cuenta corriente para algunos clientes
                if(i % 2 == 0) {
                    Model.CuentaCorrienteUDT cc = new Model.CuentaCorrienteUDT("CC" + i, "ESCORR" + i, 2000.0 * i, new Date(), 300.0, sucursal);
                    cli.getCuentas().add(cc);
                    cc.clientes.add(cli);
                    db.store(cc);
                }

                db.store(cli);
                db.store(ca);
            }
            db.commit();

            // Insertar operaciones adicionales para clientes nuevos
            // Por cada cuenta de ahorro creada adicional, insertar un ingreso y una retirada
            List<Model.CuentaUDT> nuevasCuentas = db.query(Model.CuentaUDT.class);
            int opCode = 10;
            for (Model.CuentaUDT cuenta : nuevasCuentas) {
                // Crear ingreso si el saldo es menor a 5000
                if(cuenta.saldo < 5000) {
                    Model.IngresoUDT ing = new Model.IngresoUDT(opCode++, new Date(), 500.0, "Ingreso adicional", cuenta, sucursal);
                    cuenta.getOperaciones().add(ing);
                    db.store(ing);
                }
                // Crear retirada si el saldo es mayor a 1000
                if(cuenta.saldo > 1000) {
                    Model.RetiradaUDT ret = new Model.RetiradaUDT(opCode++, new Date(), 200.0, "Retirada adicional", cuenta, sucursal);
                    cuenta.getOperaciones().add(ret);
                    db.store(ret);
                }
            }
            db.commit();

            // --- Consultas Adicionales ---
            // Consulta A: Obtener todas las operaciones de tipo Ingreso
            System.out.println("--- Todas las Operaciones de Ingreso ---");
            List<Model.IngresoUDT> ingresos = db.query(Model.IngresoUDT.class);
            for (Model.IngresoUDT ing : ingresos) {
                System.out.println("Ingreso: " + ing.descripcion + ", monto: " + ing.cantidad);
            }

            // Consulta B: Obtener todas las operaciones de tipo Retirada
            System.out.println("--- Todas las Operaciones de Retirada ---");
            List<Model.RetiradaUDT> retiradas = db.query(Model.RetiradaUDT.class);
            for (Model.RetiradaUDT ret : retiradas) {
                System.out.println("Retirada: " + ret.descripcion + ", monto: " + ret.cantidad);
            }

            // Consulta C: Obtener todas las transferencias
            System.out.println("--- Todas las Transferencias ---");
            List<Model.TransferenciaUDT> transferencias = db.query(Model.TransferenciaUDT.class);
            for (Model.TransferenciaUDT trans : transferencias) {
                System.out.println("Transferencia: " + trans.descripcion + ", monto: " + trans.cantidad);
            }

            // Consulta D: Obtener cuentas con saldo mayor a 2000
            System.out.println("--- Cuentas con saldo mayor a 2000 ---");
            Query qSaldo = db.query();
            qSaldo.constrain(Model.CuentaUDT.class);
            qSaldo.descend("saldo").constrain(2000.0).greater();
            List<Model.CuentaUDT> cuentasConSaldoAlto = qSaldo.execute();
            for (Model.CuentaUDT cta : cuentasConSaldoAlto) {
                System.out.println(cta);
            }

            // Consulta E: Obtener clientes con más de una cuenta
            System.out.println("--- Clientes con más de una cuenta ---");
            for (Model.ClienteUDT c : db.query(Model.ClienteUDT.class)) {
                if(c.getCuentas().size() > 1) {
                    System.out.println(c + " - Número de cuentas: " + c.getCuentas().size());
                }
            }

            // Consulta F: Recuperar operaciones ordenadas por monto descendente
            System.out.println("--- Operaciones ordenadas por monto descendente ---");
            Query qOrden = db.query();
            qOrden.constrain(Model.OperacionBancariaUDT.class);
            qOrden.descend("cantidad").orderDescending();
            List<Model.OperacionBancariaUDT> opsOrdenadas = qOrden.execute();
            for (Model.OperacionBancariaUDT op : opsOrdenadas) {
                System.out.println("Operación: " + op.descripcion + ", monto: " + op.cantidad);
            }

        } finally {
            db.close();
        }
    }
}
