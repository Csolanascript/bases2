package uni;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.PersistenceException;
import java.util.Date;

public class Test3 {
    EntityManagerFactory entityManagerFactory = 
            Persistence.createEntityManagerFactory("UnidadPersistenciaBanco");
    EntityManager em = entityManagerFactory.createEntityManager();
    
    public void prueba() {
        // Create offices
        Sucursal o1 = new Sucursal();
        o1.setCodigoOficina("1001");
        o1.setDireccion("Gran Vía 123, Madrid");
        o1.setTelefono("915555555");
        
        Sucursal o2 = new Sucursal();
        o2.setCodigoOficina("1002");
        o2.setDireccion("Calle Mayor 45, Barcelona");
        o2.setTelefono("935555555");

        EntityTransaction trans = em.getTransaction();
        trans.begin();
        try {
            em.persist(o1);
            em.persist(o2);
            trans.commit();
            System.out.println("Oficinas creadas correctamente");
        } catch (PersistenceException e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            System.out.println("ERROR persistiendo oficinas: " + e.getMessage());
        }
        
        // Create clients
        Cliente c1 = new Cliente();
        c1.setDni("12345678A");
        c1.setNombre("Juan Pérez");
        c1.setDireccion("Calle Alcalá 100, Madrid");
        
        Cliente c2 = new Cliente();
        c2.setDni("87654321B");
        c2.setNombre("María López");
        c2.setDireccion("Paseo de Gracia 78, Barcelona");
        
        trans.begin();
        try {
            em.persist(c1);
            em.persist(c2);
            trans.commit();
            System.out.println("Clientes creados correctamente");
        } catch (PersistenceException e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            System.out.println("ERROR persistiendo clientes: " + e.getMessage());
        }
        
        // Create accounts
        Cuenta cuenta1 = new Cuenta();
        cuenta1.setIBAN("ES1234567890123456789012");
        cuenta1.setNumerocuenta(123456);
        cuenta1.setFechaCreacion(new Date());
        cuenta1.setSaldo(1000);
        
        Cuenta cuenta2 = new Cuenta();
        cuenta2.setIBAN("ES9876543210987654321098");
        cuenta2.setNumerocuenta(654321);
        cuenta2.setFechaCreacion(new Date());
        cuenta2.setSaldo(2500);
        
        // Add accounts to clients and clients to accounts
        cuenta1.addCliente(c1);
        cuenta2.addCliente(c2);
        
        trans.begin();
        try {
            em.persist(cuenta1);
            em.persist(cuenta2);
            trans.commit();
            System.out.println("Cuentas creadas correctamente");
        } catch (PersistenceException e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            System.out.println("ERROR persistiendo cuentas: " + e.getMessage());
        }
        
        // Create operations
        
        // 1. Cash deposit
        Retirada deposito = new Retirada();
        deposito.setCodigoOperacion(1);
        deposito.setFechaHora(new Date());
        deposito.setCantidad(500);
        deposito.setCuentaOrigen(cuenta1);
        deposito.setDescripcion("Ingreso en efectivo");
        deposito.setTipoOperacion(Retirada.TipoOperacionEfectivo.INGRESO);
        deposito.setOficina(o1);
        
        // 2. Cash withdrawal
        Retirada retirada = new Retirada();
        retirada.setCodigoOperacion(2);
        retirada.setFechaHora(new Date());
        retirada.setCantidad(200);
        retirada.setCuentaOrigen(cuenta2);
        retirada.setDescripcion("Retirada en efectivo");
        retirada.setTipoOperacion(Retirada.TipoOperacionEfectivo.RETIRADA);
        retirada.setOficina(o2);
        // 3. Transfer between accounts
        Transferencia transferencia = new Transferencia();
        transferencia.setCodigoOperacion(3);
        transferencia.setFechaHora(new Date());
        transferencia.setCantidad(300);
        transferencia.setCuentaOrigen(cuenta1);
        transferencia.setCuentaDestino(cuenta2);
        transferencia.setDescripcion("Transferencia mensual");
        
        trans.begin();
        try {
            em.persist(deposito);
            em.persist(retirada);
            em.persist(transferencia);
            
            // Update account balances
            cuenta1.setSaldo((long) (cuenta1.getSaldo() + deposito.getCantidad() - transferencia.getCantidad()));
            cuenta2.setSaldo((long) (cuenta2.getSaldo() - retirada.getCantidad() + transferencia.getCantidad()));
            
            em.merge(cuenta1);
            em.merge(cuenta2);
            
            trans.commit();
            
            System.out.println("Operaciones bancarias realizadas correctamente:");
            System.out.println("Depósito: " + deposito);
            System.out.println("Retirada: " + retirada);
            System.out.println("Transferencia: " + transferencia);
            System.out.println("Nuevo saldo cuenta1: " + cuenta1.getSaldo());
            System.out.println("Nuevo saldo cuenta2: " + cuenta2.getSaldo());
            
        } catch (PersistenceException e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            System.out.println("ERROR persistiendo operaciones: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
            entityManagerFactory.close();
        }
    }
    
    public static void main(String[] args) {
        Test3 t = new Test3();
        t.prueba();
    }
}