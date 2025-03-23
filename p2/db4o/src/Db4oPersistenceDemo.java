import com.db4o.Db4oEmbedded;
import com.db4o.ObjectContainer;
import com.db4o.query.Query;
import java.util.Date;
import java.util.List;

public class Db4oPersistenceDemo {

    public static void main(String[] args) {
        ObjectContainer db = Db4oEmbedded.openFile("banco.db4o");

        try {
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

            // Operaciones bancarias
            Model.IngresoUDT ingreso = new Model.IngresoUDT(1, new Date(), 300.0, "Depósito inicial", cuentaAhorro, sucursal);
            Model.RetiradaUDT retirada = new Model.RetiradaUDT(2, new Date(), 100.0, "Retiro cajero", cuentaCorriente, sucursal);
            Model.TransferenciaUDT transferencia = new Model.TransferenciaUDT(3, new Date(), 200.0, "Transferencia interna", cuentaCorriente, cuentaAhorro);

            // Vincular operaciones a cuentas
            cuentaAhorro.getOperaciones().add(ingreso);
            cuentaCorriente.getOperaciones().add(retirada);
            cuentaCorriente.getOperaciones().add(transferencia);

            // Almacenar objetos en Db4o
            db.store(sucursal);
            db.store(cliente);
            db.store(cuentaAhorro);
            db.store(cuentaCorriente);

            db.commit();

            // Consultas sencillas

            // Consulta 1: Obtener todos los clientes
            System.out.println("--- Clientes ---");
            List<Model.ClienteUDT> clientes = db.query(Model.ClienteUDT.class);
            for (Model.ClienteUDT c : clientes) {
                System.out.println(c);
            }

            // Consulta general: recupera todas las cuentas (Corrientes y Ahorro)
            List<Model.CuentaUDT> todasLasCuentas = db.query(Model.CuentaUDT.class);
            System.out.println("--- Todas las cuentas (Corrientes y Ahorro) ---");
            for (Model.CuentaUDT cuenta : todasLasCuentas) {
                System.out.println(cuenta);
            }


            // Consulta 3: Obtener operaciones bancarias con monto mayor a 150
            System.out.println("--- Operaciones mayores a 150 ---");
            Query q = db.query();
            q.constrain(Model.OperacionBancariaUDT.class);
            q.descend("Cantidad").constrain(150.0).greater();
            List<Model.OperacionBancariaUDT> operaciones = q.execute();
            for (Model.OperacionBancariaUDT op : operaciones) {
                System.out.println("Operación: " + op.descripcion + ", monto: " + op.cantidad);
            }

        } finally {
            db.close();
        }
    }
}