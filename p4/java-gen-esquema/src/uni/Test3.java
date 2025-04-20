package uni;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.PersistenceException;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Root;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Join;
import javax.persistence.criteria.Expression;

import java.util.Date;
import java.util.List;

public class Test3 {
    // Note: The persistence unit name here must match the one in persistence.xml.
    EntityManagerFactory entityManagerFactory = 
            Persistence.createEntityManagerFactory("UnidadPersistenciaBanco");
    EntityManager em = entityManagerFactory.createEntityManager();
    
    public void prueba() {        
        // ----- Create Offices -----
        Oficina o1 = new Oficina();
        o1.setCodigoOficina("1001");
        o1.setDireccion("Gran Vía 123, Madrid");
        o1.setTelefono("915555555");
        
        Oficina o2 = new Oficina();
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
            if (trans.isActive()) trans.rollback();
            System.out.println("ERROR persistiendo oficinas: " + e.getMessage());
        }
        
    // ----- Create Clients -----
        Cliente c1 = new Cliente();
        Direccion d1 = new Direccion();
        d1.setCalle("Calle Alfonso I 23");
        d1.setCodigoPostal("50010");
        d1.setCiudad("Zaragoza");
        em.persist(d1);

        c1.setDni("12345678A");
        c1.setNombre("Juan Pérez");
        c1.setDireccion(d1);
        c1.setApellidos("García Pérez"); 
        c1.setTelefono("600000000");
        c1.setEmail("hola@hotmail");
        c1.setEdad(30);

        Cliente c2 = new Cliente();
        Direccion d2 = new Direccion();
        d2.setCalle("Avenida Diagonal 456");
        d2.setCodigoPostal("08013");
        d2.setCiudad("Barcelona"); 
        em.persist(d2);

        c2.setDni("87654321B");
        c2.setNombre("María López");
        c2.setApellidos("García López"); 
        c2.setTelefono("600000001");
        c2.setEmail("hola@gmail");
        c2.setEdad(25);
        c2.setDireccion(d2);

        Cliente c3 = new Cliente();
        Direccion d3 = new Direccion();
        d3.setCalle("Calle Gran Vía 200");
        d3.setCodigoPostal("28002");
        d3.setCiudad("Madrid");
        em.persist(d3);

        c3.setDni("23456789C");
        c3.setNombre("Ana García");
        c3.setApellidos("López García");
        c3.setTelefono("600000002");
        c3.setEmail("hola1@gmail");
        c3.setEdad(28);
        c3.setDireccion(d3);

        Cliente c4 = new Cliente();
        Direccion d4 = new Direccion();
        d4.setCalle("Calle de Vallehermoso 100");
        d4.setCodigoPostal("28015");
        d4.setCiudad("Madrid");
        em.persist(d4);

        c4.setDni("34567890D");
        c4.setNombre("Luis Fernández");
        c4.setApellidos("Fernández López");
        c4.setTelefono("600000003");
        c4.setEmail("hola2@gmail");
        c4.setEdad(35);
        c4.setDireccion(d4);

        

        trans.begin();
        try {
            em.persist(c1);
            em.persist(c2);
            em.persist(c3);
            em.persist(c4);
            trans.commit();
            System.out.println("Clientes creados correctamente");
        } catch (PersistenceException e) {
            if (trans.isActive()) trans.rollback();
            System.out.println("ERROR persistiendo clientes: " + e.getMessage());
        }
        
        // ----- Create Accounts -----
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

        Cuenta cuenta3 = new Cuenta();
        cuenta3.setIBAN("ES1111111111111111111111");
        cuenta3.setNumerocuenta(111111);
        cuenta3.setFechaCreacion(new Date());
        cuenta3.setSaldo(5000);
        
        Cuenta cuenta4 = new Cuenta();
        cuenta4.setIBAN("ES2222222222222222222222");
        cuenta4.setNumerocuenta(222222);
        cuenta4.setFechaCreacion(new Date());
        cuenta4.setSaldo(3000);
        // Associate accounts with clients (bidirectional association)
        cuenta1.addCliente(c1);
        cuenta2.addCliente(c2);
        cuenta3.addCliente(c3);
        cuenta4.addCliente(c4);
        
        trans.begin();
        try {
            em.persist(cuenta1);
            em.persist(cuenta2);
            em.persist(cuenta3);
            em.persist(cuenta4);
            trans.commit();
            System.out.println("Cuentas creadas correctamente");
        } catch (PersistenceException e) {
            if (trans.isActive()) trans.rollback();
            System.out.println("ERROR persistiendo cuentas: " + e.getMessage());
        }
        
        // ----- Create Operations -----
        // 1. Cash deposit (Ingreso)
        OperacionEfectivo deposito = new OperacionEfectivo();
        deposito.setCodigoOperacion(1);
        deposito.setFechaHora(new Date());
        deposito.setCantidad(500);
        deposito.setCuentaOrigen(cuenta1);
        deposito.setDescripcion("Ingreso en efectivo");
        deposito.setTipoOperacion(OperacionEfectivo.TipoOperacionEfectivo.INGRESO);
        deposito.setOficina(o1);
        
        // 2. Cash withdrawal (Retirada)
        OperacionEfectivo retirada = new OperacionEfectivo();
        retirada.setCodigoOperacion(2);
        retirada.setFechaHora(new Date());
        retirada.setCantidad(200);
        retirada.setCuentaOrigen(cuenta2);
        retirada.setDescripcion("Retirada en efectivo");
        retirada.setTipoOperacion(OperacionEfectivo.TipoOperacionEfectivo.RETIRADA);
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
            cuenta1.setSaldo((long)(cuenta1.getSaldo() + deposito.getCantidad() - transferencia.getCantidad()));
            cuenta2.setSaldo((long)(cuenta2.getSaldo() - retirada.getCantidad()+ transferencia.getCantidad()));
            
            em.merge(cuenta1);
            em.merge(cuenta2);
            
            trans.commit();
            
            System.out.println("Operaciones bancarias realizadas correctamente:");
            System.out.println("Depósito: " + deposito);
            System.out.println("Retirada: " + retirada);
            //System.out.println("Transferencia: " + transferencia);
            System.out.println("Nuevo saldo cuenta1: " + cuenta1.getSaldo());
            System.out.println("Nuevo saldo cuenta2: " + cuenta2.getSaldo());



            // ----- Querying the database -----
            // 1. Devolver el saldo medio de las cuentas de los clientes agrupado por ciudad
        //JPQL
        List<Object[]> mediasPorCiudad = em.createQuery(
        "SELECT d.Ciudad, AVG(cu.Saldo) " + //Seleccionamos la ciudad y el saldo medio
        "  FROM Cliente cli " + //Desde la entidad Cliente
        "  JOIN cli.Direccion d " +   //Join con la entidad Direccion
        "  JOIN cli.Cuentas cu " +    //Join con la entidad Cuenta
        " GROUP BY d.Ciudad" +  //Agrupamos resultados por ciudad
        " ORDER BY AVG(cu.Saldo) DESC", Object[].class) //Ordenamos por saldo medio
        .getResultList();

        System.out.println("Resultado JPQL:");
        //Mostramos el resultado de la consulta
        for (Object[] fila : mediasPorCiudad) {
            String ciudad = (String) fila[0];
            Double saldoMedio = (Double) fila[1];
            System.out.printf("Ciudad: %s → Saldo medio: %.2f%n", ciudad, saldoMedio);
        }


        //Criteria API
        // 1. Obtenemos el CriteriaBuilder y creamos un CriteriaQuery que devuelva Object[]
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Object[]> cq = cb.createQuery(Object[].class);

        // 2. Definimos la raíz de la consulta sobre Cliente
        Root<Cliente> cliente = cq.from(Cliente.class);

        // 3. Hacemos los joins a las asociaciones de Cliente
        Join<Cliente,Direccion> joinDir = cliente.join("Direccion");
        Join<Cliente,Cuenta>    joinCta = cliente.join("Cuentas");


        // Expresión de promedio
        Expression<Double> avgSaldo = cb.avg(joinCta.get("Saldo"));
        // 4. Seleccionamos dos cosas:
        // Construcción de la consulta
        cq.multiselect(
            joinDir.get("Ciudad"),
            avgSaldo
        );
        
        // 5. Definimos la cláusula GROUP BY y ORDER BY
        cq.groupBy(joinDir.get("Ciudad"));
        cq.orderBy(cb.desc(avgSaldo));
        
        // 6. Ejecutamos la consulta
        List<Object[]> resultados = em.createQuery(cq).getResultList();

        System.out.println("Resultado Criteria API:");
        // 7. Procesamos resultados
        for (Object[] fila : resultados) {
            String ciudad    = (String) fila[0];
            Double saldMedio = (Double) fila[1];
            System.out.printf("Ciudad=%s → Saldo medio=%.2f%n", ciudad, saldMedio);
        }

        //SQL Nativo
        @SuppressWarnings("unchecked")
        List<Object[]> resultadosNativo = em.createNativeQuery(
        "SELECT d.CIUDAD, AVG(c.SALDO) AS SaldoMedio " + //Seleccionamos la ciudad y el saldo medio
        "  FROM CLIENTE cli " + //Desde la entidad Cliente
        "  JOIN DIRECCION d  " + //Join con la entidad Direccion
        "    ON cli.DIRECCION_ID_DIRECCION = d.ID_DIRECCION " + //Sobre el id de Direccion
        "  JOIN CLIENTES_CUENTAS cc  " + //Join con la tabla intermedia CLIENTES_CUENTAS
        "    ON cli.DNI = cc.CLIENTE_DNI " + //Sobre el dni de Cliente
        "  JOIN CUENTA c  " + //Join con la entidad Cuenta
        "    ON cc.CUENTA_ID = c.IBAN " + //Sobre el id de Cuenta
        " GROUP BY d.CIUDAD" + // //Agrupamos resultados por ciudad
        " ORDER BY SaldoMedio DESC"           // añadimos orden descendente
        ).getResultList();

        System.out.println("Resultado SQL Nativo:");
        for (Object[] fila : resultadosNativo) {
            String ciudad    = (String) fila[0];
            Number saldMedio = (Number) fila[1];
            System.out.printf("Ciudad=%s → Saldo medio=%.2f%n",
                      ciudad, saldMedio.doubleValue());
        }




        } catch (PersistenceException e) {
            if (trans.isActive()) trans.rollback();
            System.out.println("ERROR persistiendo operaciones: " + e.getMessage());
            e.printStackTrace();
        }

        finally {
            em.close();
            entityManagerFactory.close();
        }
    }
    
    public static void main(String[] args) {
        Test3 t = new Test3();
        t.prueba();
    }
}