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
    EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("UnidadPersistenciaBanco");
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
            if (trans.isActive())
                trans.rollback();
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
            if (trans.isActive())
                trans.rollback();
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

        // Crear cliente especial para probar la consulta
        Cliente testCliente = new Cliente();
        Direccion testDir = new Direccion();
        testDir.setCalle("Calle Test");
        testDir.setCodigoPostal("50001");
        testDir.setCiudad("Zaragoza");
        em.persist(testDir);

        testCliente.setDni("99999999Z");
        testCliente.setNombre("Cliente Test");
        testCliente.setApellidos("Apellido Test");
        testCliente.setEdad(40);
        testCliente.setDireccion(testDir);
        testCliente.setTelefono("600123456");
        testCliente.setEmail("cliente@test.com");

        // Crear cuenta asociada
        Cuenta cuentaTest = new Cuenta();
        cuentaTest.setIBAN("TESTCY9999999999999999");
        cuentaTest.setNumerocuenta(999999);
        cuentaTest.setFechaCreacion(new Date());
        cuentaTest.setSaldo(100000);

        CuentaCorriente cuentaCorrienteTest = new CuentaCorriente();
        cuentaCorrienteTest.setIBAN("TESTCC9999999999999999");
        cuentaCorrienteTest.setNumerocuenta(999998);
        cuentaCorrienteTest.setFechaCreacion(new Date());
        cuentaCorrienteTest.setSaldo(50000);

        Cliente testCliente2 = new Cliente();
        testCliente2.setDni("88888888Y");
        testCliente2.setNombre("Cliente Test 2");
        testCliente2.setApellidos("Apellido Test 2");
        testCliente2.setEdad(35);
        testCliente2.setDireccion(testDir);
        testCliente2.setTelefono("600654321");
        testCliente.addCuenta(cuentaCorrienteTest);

        Oficina oficinaTest = new Oficina();
        oficinaTest.setCodigoOficina("9999");
        oficinaTest.setDireccion("Calle Test 123, Zaragoza");
        oficinaTest.setTelefono("600000000");
        em.persist(oficinaTest);
        cuentaCorrienteTest.setOficina(oficinaTest);

        // Asociar cliente y cuenta
        cuentaCorrienteTest.addCliente(testCliente);

        em.persist(testCliente);
        em.persist(cuentaTest);
        em.persist(cuentaCorrienteTest);

        // Crear cuenta destino para la transferencia
        Cuenta cuentaDestino = new Cuenta();
        cuentaDestino.setIBAN("DESTINO99999999999999999");
        cuentaDestino.setNumerocuenta(888888);
        cuentaDestino.setFechaCreacion(new Date());
        cuentaDestino.setSaldo(1000);
        em.persist(cuentaDestino);

        // Crear transferencia válida (>500€, menos de 3 meses)
        Transferencia trTest = new Transferencia();
        trTest.setCodigoOperacion(99);
        trTest.setFechaHora(new Date()); // Hoy
        trTest.setCantidad(750.0); // > 500 €
        trTest.setCuentaOrigen(cuentaTest);
        trTest.setCuentaDestino(cuentaDestino);
        trTest.setDescripcion("Transferencia de prueba");

        // Persistir la transferencia
        em.persist(trTest);

        // Actualizar saldos
        cuentaTest.setSaldo((long) (cuentaTest.getSaldo() - trTest.getCantidad()));
        cuentaDestino.setSaldo((long) (cuentaDestino.getSaldo() + trTest.getCantidad()));

        em.merge(cuentaTest);
        em.merge(cuentaDestino);

        trans.begin();
        try {
            em.persist(cuenta1);
            em.persist(cuenta2);
            em.persist(cuenta3);
            em.persist(cuenta4);
            trans.commit();
            System.out.println("Cuentas creadas correctamente");
        } catch (PersistenceException e) {
            if (trans.isActive())
                trans.rollback();
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
            cuenta1.setSaldo((long) (cuenta1.getSaldo() + deposito.getCantidad() - transferencia.getCantidad()));
            cuenta2.setSaldo((long) (cuenta2.getSaldo() - retirada.getCantidad() + transferencia.getCantidad()));

            em.merge(cuenta1);
            em.merge(cuenta2);

            trans.commit();

            System.out.println("Operaciones bancarias realizadas correctamente:");
            System.out.println("Depósito: " + deposito);
            System.out.println("Retirada: " + retirada);
            // System.out.println("Transferencia: " + transferencia);
            System.out.println("Nuevo saldo cuenta1: " + cuenta1.getSaldo());
            System.out.println("Nuevo saldo cuenta2: " + cuenta2.getSaldo());

            // ----- Querying the database -----
            // 1. Devolver el saldo medio de las cuentas de los clientes agrupado por ciudad
            // JPQL
            List<Object[]> mediasPorCiudad = em.createQuery(
                    "SELECT d.Ciudad, AVG(cu.Saldo) " +
                            "  FROM Cliente cli " +
                            "  JOIN cli.Direccion d " +
                            "  JOIN cli.Cuentas cu " +
                            " GROUP BY d.Ciudad" +
                            " ORDER BY AVG(cu.Saldo) DESC",
                    Object[].class)
                    .getResultList();

            System.out.println("Resultado JPQL:");
            // Mostramos el resultado de la consulta
            for (Object[] fila : mediasPorCiudad) {
                String ciudad = (String) fila[0];
                Double saldoMedio = (Double) fila[1];
                System.out.printf("Ciudad: %s → Saldo medio: %.2f%n", ciudad, saldoMedio);
            }

            // Criteria API
            // 1. Obtenemos el CriteriaBuilder y creamos un CriteriaQuery que devuelva
            // Object[]
            CriteriaBuilder cb = em.getCriteriaBuilder();
            CriteriaQuery<Object[]> cq = cb.createQuery(Object[].class);

            // 2. Definimos la raíz de la consulta sobre Cliente
            Root<Cliente> cliente = cq.from(Cliente.class);

            // 3. Hacemos los joins a las asociaciones de Cliente
            Join<Cliente, Direccion> joinDir = cliente.join("Direccion");
            Join<Cliente, Cuenta> joinCta = cliente.join("Cuentas");

            // Expresión de promedio
            Expression<Double> avgSaldo = cb.avg(joinCta.get("Saldo"));
            // 4. Seleccionamos dos cosas:
            // Construcción de la consulta
            cq.multiselect(
                    joinDir.get("Ciudad"),
                    avgSaldo);

            // 5. Definimos la cláusula GROUP BY y ORDER BY
            cq.groupBy(joinDir.get("Ciudad"));
            cq.orderBy(cb.desc(avgSaldo));

            // 6. Ejecutamos la consulta
            List<Object[]> resultados = em.createQuery(cq).getResultList();

            System.out.println("Resultado Criteria API:");
            // 7. Procesamos resultados
            for (Object[] fila : resultados) {
                String ciudad = (String) fila[0];
                Double saldMedio = (Double) fila[1];
                System.out.printf("Ciudad=%s → Saldo medio=%.2f%n", ciudad, saldMedio);
            }

            // SQL Nativo
            @SuppressWarnings("unchecked")
            List<Object[]> resultadosNativo = em.createNativeQuery(
                    "SELECT d.CIUDAD, AVG(c.SALDO) AS SaldoMedio " + // Seleccionamos la ciudad y el saldo medio
                            "  FROM CLIENTE cli " + // Desde la entidad Cliente
                            "  JOIN DIRECCION d  " + // Join con la entidad Direccion
                            "    ON cli.DIRECCION_ID_DIRECCION = d.ID_DIRECCION " + // Sobre el id de Direccion
                            "  JOIN CLIENTES_CUENTAS cc  " + // Join con la tabla intermedia CLIENTES_CUENTAS
                            "    ON cli.DNI = cc.CLIENTE_DNI " + // Sobre el dni de Cliente
                            "  JOIN CUENTA c  " + // Join con la entidad Cuenta
                            "    ON cc.CUENTA_ID = c.IBAN " + // Sobre el id de Cuenta
                            " GROUP BY d.CIUDAD" + // //Agrupamos resultados por ciudad
                            " ORDER BY SaldoMedio DESC" // añadimos orden descendente
            ).getResultList();

            System.out.println("Resultado SQL Nativo:");
            for (Object[] fila : resultadosNativo) {
                String ciudad = (String) fila[0];
                Number saldMedio = (Number) fila[1];
                System.out.printf("Ciudad=%s → Saldo medio=%.2f%n",
                        ciudad, saldMedio.doubleValue());
            }

        } catch (PersistenceException e) {
            if (trans.isActive())
                trans.rollback();
            System.out.println("ERROR persistiendo operaciones: " + e.getMessage());
            e.printStackTrace();
        }

        trans.begin();
        try {
            // First calculate average account balance
            Double avgBalance = (Double) em.createQuery(
                    "SELECT AVG(c.Saldo) FROM Cuenta c")
                    .getSingleResult();

            System.out.println("Saldo medio de todas las cuentas: " + avgBalance);

            // JPQL query for branches with most clients with above-average balance
            List<Object[]> sucursalConMasClientes = em.createQuery(
                    "SELECT o.codigoOficina, o.direccion, o.telefono, COUNT(DISTINCT cli) " +
                            "FROM Oficina o " +
                            "JOIN o.cuentas c " +
                            "JOIN c.Clientes cli " +
                            "WHERE c.Saldo > :avgBalance " +
                            "GROUP BY o.codigoOficina, o.direccion, o.telefono " +
                            "ORDER BY COUNT(DISTINCT cli) DESC",
                    Object[].class)
                    .setParameter("avgBalance", avgBalance.longValue())
                    .setMaxResults(1)
                    .getResultList();

            if (!sucursalConMasClientes.isEmpty()) {
                Object[] resultado = sucursalConMasClientes.get(0);
                String codigoOficina = (String) resultado[0];
                String direccion = (String) resultado[1];
                String telefono = (String) resultado[2];
                Long numeroClientes = (Long) resultado[3];

                System.out.printf("\n" + "Sucursal con más clientes con saldo superior a la media (%.2f): " +
                        "Código: %s, Dirección: %s, Teléfono: %s, Clientes: %d%n",
                        avgBalance, codigoOficina, direccion, telefono, numeroClientes);
            } else {
                System.out.println("No se encontraron sucursales con clientes que tengan saldo superior a la media");
            }

            Double avgBalance1 = (Double) em.createQuery(
                    "SELECT AVG(c.Saldo) FROM Cuenta c")
                    .getSingleResult();
            System.out.println("Saldo medio de todas las cuentas: " + avgBalance1);

            // SQL Native query for branches with most clients with above-average balance
            @SuppressWarnings("unchecked")
            List<Object[]> sucursalConMasClientesNativo = em.createNativeQuery(
                    "SELECT o.CODIGO_OFICINA, o.DIRECCION, o.TELEFONO, COUNT(DISTINCT cli.DNI) as NUM_CLIENTES " +
                            "FROM OFICINA o " +
                            "LEFT JOIN CUENTACORRIENTE cc ON o.CODIGO_OFICINA = cc.OFICINA_CODIGO_OFICINA " +
                            "LEFT JOIN CUENTA c ON cc.IBAN = c.IBAN " +
                            "JOIN CLIENTES_CUENTAS cc_junction ON c.IBAN = cc_junction.CUENTA_ID " +
                            "JOIN CLIENTE cli ON cc_junction.CLIENTE_DNI = cli.DNI " +
                            "WHERE c.SALDO > ? " +
                            "GROUP BY o.CODIGO_OFICINA, o.DIRECCION, o.TELEFONO " +
                            "ORDER BY NUM_CLIENTES DESC")
                    .setParameter(1, avgBalance1.longValue())
                    .setMaxResults(1)
                    .getResultList();

            if (!sucursalConMasClientesNativo.isEmpty()) {
                Object[] resultado = sucursalConMasClientesNativo.get(0);
                String codigoOficina = (String) resultado[0];
                String direccion = (String) resultado[1];
                String telefono = (String) resultado[2];
                Number numeroClientes = (Number) resultado[3];

                System.out.printf(
                        "\n" + "SQL Nativo - Sucursal con más clientes con saldo superior a la media (%.2f): " +
                                "Código: %s, Dirección: %s, Teléfono: %s, Clientes: %d%n",
                        avgBalance, codigoOficina, direccion, telefono, numeroClientes.longValue());
            }

            // 2. Criteria API version
            CriteriaBuilder cb = em.getCriteriaBuilder();

            // First get average balance (already calculated above)

            // Now build the query for offices with clients having above-average balances
            CriteriaQuery<Object[]> cq = cb.createQuery(Object[].class);
            Root<Oficina> oficinaRoot = cq.from(Oficina.class);

            // Join to associated accounts and then to clients
            Join<Oficina, Cuenta> joinCuentas = oficinaRoot.join("cuentas");
            Join<Cuenta, Cliente> joinClientes = joinCuentas.join("Clientes");

            // COUNT distinct clients
            Expression<Long> countClients = cb.countDistinct(joinClientes);

            // Select office attributes and client count
            cq.multiselect(
                    oficinaRoot.get("codigoOficina"),
                    oficinaRoot.get("direccion"),
                    oficinaRoot.get("telefono"),
                    countClients);

            // Add WHERE clause for above-average balance
            cq.where(cb.gt(joinCuentas.get("Saldo"), avgBalance.longValue()));

            // Group by office fields
            cq.groupBy(
                    oficinaRoot.get("codigoOficina"),
                    oficinaRoot.get("direccion"),
                    oficinaRoot.get("telefono"));

            // Order by client count descending
            cq.orderBy(cb.desc(countClients));

            // Execute and get results
            List<Object[]> sucursalConMasClientesCriteria = em.createQuery(cq)
                    .setMaxResults(1)
                    .getResultList();

            if (!sucursalConMasClientesCriteria.isEmpty()) {
                Object[] resultado = sucursalConMasClientesCriteria.get(0);
                String codigoOficina = (String) resultado[0];
                String direccion = (String) resultado[1];
                String telefono = (String) resultado[2];
                Long numeroClientes = (Long) resultado[3];

                System.out.printf(
                        "\n " + "Criteria API - Sucursal con más clientes con saldo superior a la media (%.2f): " +
                                "Código: %s, Dirección: %s, Teléfono: %s, Clientes: %d%n",
                        avgBalance, codigoOficina, direccion, telefono, numeroClientes);
            }
        } catch (PersistenceException e) {
            if (trans.isActive())
                trans.rollback();
            System.out.println("ERROR en consulta de sucursales: " + e.getMessage());
            e.printStackTrace();
        }

        try {
            Date fechaLimite = new Date(System.currentTimeMillis() - 90L * 24 * 60 * 60 * 1000); // 3 meses

            List<Cliente> clientesTransferencias = em.createQuery(
                    "SELECT DISTINCT c " +
                            "FROM Cliente c " +
                            "JOIN c.Cuentas cuenta " +
                            "JOIN cuenta.operaciones op " +
                            "WHERE TYPE(op) = Transferencia " +
                            "AND op.cantidad > 500 " +
                            "AND op.fechaHora >= :fechaLimite",
                    Cliente.class)
                    .setParameter("fechaLimite", fechaLimite)
                    .getResultList();

            System.out.println("Clientes con transferencias > 500€ en los últimos 3 meses (JPQL):");
            for (Cliente c : clientesTransferencias) {
                System.out.println(c);
            }

            CriteriaBuilder cb = em.getCriteriaBuilder();
            CriteriaQuery<Cliente> cq = cb.createQuery(Cliente.class);

            Root<Cliente> clienteRoot = cq.from(Cliente.class);
            Join<Cliente, Cuenta> joinCuenta = clienteRoot.join("Cuentas");
            Join<Cuenta, Operacion> joinOperacion = joinCuenta.join("operaciones");

            // ¡Aquí filtramos por clase Transferencia!
            cq.select(clienteRoot).distinct(true)
                    .where(
                            cb.and(
                                    cb.equal(joinOperacion.type(), Transferencia.class),
                                    cb.greaterThan(joinOperacion.<Double>get("cantidad"), 500.0),
                                    cb.greaterThanOrEqualTo(joinOperacion.<Date>get("fechaHora"), fechaLimite)));

            List<Cliente> resultados = em.createQuery(cq).getResultList();

            System.out.println("Resultado Criteria API (transferencias >500€ en últimos 3 meses):");
            for (Cliente c : resultados) {
                System.out.println(c);
            }

            @SuppressWarnings("unchecked")
            List<Object[]> resultadosSQLNative = em.createNativeQuery(
                    "SELECT DISTINCT c.* " +
                            "FROM CLIENTE c " +
                            "JOIN CLIENTES_CUENTAS cc ON c.DNI = cc.CLIENTE_DNI " +
                            "JOIN CUENTA cu ON cc.CUENTA_ID = cu.IBAN " +
                            "JOIN OPERACION op ON cu.IBAN = op.CUENTA_ORIGEN_IBAN " +
                            "JOIN TRANSFERENCIA t ON t.CODIGO_OPERACION = op.CODIGO_OPERACION AND t.CUENTA_ORIGEN_IBAN = op.CUENTA_ORIGEN_IBAN "
                            +
                            "WHERE op.CANTIDAD > 500 AND op.FECHA_HORA >= ?")
                    .setParameter(1, fechaLimite)
                    .getResultList();

            // Mostrar resultados
            System.out.println("Resultado SQL Nativo (transferencias >500€ en últimos 3 meses):");
            for (Object[] fila : resultadosSQLNative) {
                Cliente cli = new Cliente();
                cli.setDni((String) fila[0]);
                cli.setApellidos((String) fila[1]);
                cli.setEdad(((Number) fila[2]).intValue());
                cli.setEmail((String) fila[3]);
                cli.setNombre((String) fila[4]);
                cli.setTelefono((String) fila[5]);
                System.out.println(cli);
            }

        } catch (PersistenceException e) {
            System.out.println("ERROR ejecutando consulta JPQL de transferencias: " + e.getMessage());
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