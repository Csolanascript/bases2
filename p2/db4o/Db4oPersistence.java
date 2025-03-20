import com.db4o.Db4oEmbedded;
import com.db4o.ObjectContainer;
import com.db4o.query.Query;
import java.util.Date;
import java.util.List;

public class Db4oPersistence {
    public static void main(String[] args) {
        // Abrir (o crear) la base de datos en el archivo "banco.db4o"
        ObjectContainer db = Db4oEmbedded.openFile("banco.db4o");
        try {
            // Crear y almacenar algunos objetos utilizando las clases del modelo
            Model.ClienteUDT cliente = new Model.ClienteUDT(1, "Juan", "Perez", 30, "555-1234", "juan@example.com", "Calle Falsa 123", "12345678X");
            Model.CuentaAhorroUDT cuentaAhorro = new Model.CuentaAhorroUDT("1234567890", "ES1234567890", 1000.0, new Date(), "AHORRO", 1.5);
            Model.CuentaCorrienteUDT cuentaCorriente = new Model.CuentaCorrienteUDT("0987654321", "ES0987654321", 2000.0, new Date(), "CORRIENTE", 500.0);
            Model.SucursalUDT sucursal = new Model.SucursalUDT(1, "Sucursal Central", "987654321");
            Model.TransferenciaUDT transferencia = new Model.TransferenciaUDT(100, new Date(), 250.0, "Transferencia", "Pago de factura", "ES1234567890", 1, "ES1234567890", "ES0987654321");
            Model.RetiradaUDT retirada = new Model.RetiradaUDT(101, new Date(), 150.0, "Retirada", "Retiro cajero", "ES1234567890", 1, "Cajero Automático");
            Model.IngresoUDT ingreso = new Model.IngresoUDT(102, new Date(), 300.0, "Ingreso", "Depósito en cuenta", "ES0987654321", 1, "Transferencia Bancaria");

            db.store(cliente);
            db.store(cuentaAhorro);
            db.store(cuentaCorriente);
            db.store(sucursal);
            db.store(transferencia);
            db.store(retirada);
            db.store(ingreso);

            db.commit();
            System.out.println("Objetos almacenados en db4o.");

            // Consultar y mostrar todos los objetos de ClienteUDT
            Query query = db.query();
            query.constrain(Model.ClienteUDT.class);
            List<Model.ClienteUDT> clientes = query.execute();
            System.out.println("Clientes almacenados:");
            for (Model.ClienteUDT c : clientes) {
                System.out.println(c);
            }

            // Consultar y mostrar todos los objetos de OperacionBancariaUDT (incluye Transferencia, Retirada e Ingreso)
            query = db.query();
            query.constrain(Model.OperacionBancariaUDT.class);
            List<Model.OperacionBancariaUDT> operaciones = query.execute();
            System.out.println("Operaciones almacenadas:");
            for (Model.OperacionBancariaUDT op : operaciones) {
                System.out.println(op);
            }
        } finally {
            db.close();
        }
    }
}
