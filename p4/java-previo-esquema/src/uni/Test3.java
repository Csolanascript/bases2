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
    EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("UnidadPersistenciaBanco");
    EntityManager em = entityManagerFactory.createEntityManager();

    public void prueba() {
        // Create offices
        Sucursal o1 = new Sucursal();
        o1.setCodigo_sucursal(1001);
        o1.setDireccion("Madrid");
        o1.setTelefono("915555555");

        Sucursal o2 = new Sucursal();
        o2.setCodigo_sucursal(1002);
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
        c1.setDni(12345678);
        c1.setNombre("Juan");
        c1.setApellidos("Pérez");
        c1.setDireccion("Madrid");
        c1.setEdad(30);
        c1.setTelefono("600123456");
        c1.setEmail("juan.perez@example.com");

        Cliente c2 = new Cliente();
        c2.setDni(87654321);
        c2.setNombre("María");
        c2.setApellidos("López");
        c2.setDireccion("Paseo de Gracia 78, Barcelona");
        c2.setEdad(28);
        c2.setTelefono("600654321");
        c2.setEmail("maria.lopez@example.com");

        Cliente c3 = new Cliente();
        c3.setDni(11223344);
        c3.setNombre("Carlos");
        c3.setApellidos("Gómez");
        c3.setDireccion("Calle Gran Vía, Madrid");
        c3.setEdad(35);
        c3.setTelefono("600987654");
        c3.setEmail("carlos.lopez@gmail.com");

        Cliente c4 = new Cliente();
        c4.setDni(55667788);
        c4.setNombre("Ana");
        c4.setApellidos("Martínez");
        c4.setDireccion("Via Hispanidad 6, Zaragoza");
        c4.setEdad(40);
        c4.setTelefono("600123789");
        c4.setEmail("ana.martinez@gmail.com");

        trans.begin();
        try {
            em.persist(c1);
            em.persist(c2);
            em.persist(c3);
            em.persist(c4);
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

        Cuenta cuenta3 = new Cuenta();
        cuenta3.setIBAN("ES1111111111111111111111");
        cuenta3.setNumerocuenta(111111);
        cuenta3.setFechaCreacion(new Date());
        cuenta3.setSaldo(2400);

        Cuenta cuenta4 = new Cuenta();
        cuenta4.setIBAN("ES2222222222222222222222");
        cuenta4.setNumerocuenta(222222);
        cuenta4.setFechaCreacion(new Date());
        cuenta4.setSaldo(3000);

        // Add accounts to clients and clients to accounts
        cuenta1.addCliente(c1);
        cuenta2.addCliente(c2);
        cuenta3.addCliente(c3);
        cuenta4.addCliente(c4);

        // Crear cliente especial para probar la consulta
        Cliente testCliente = new Cliente();

        testCliente.setDni(99999999);
        testCliente.setNombre("Cliente Test");
        testCliente.setApellidos("Apellido Test");
        testCliente.setEdad(40);
        testCliente.setDireccion("Calle Test, 50001, Zaragoza");
        testCliente.setTelefono("600123456");
        testCliente.setEmail("cliente@test.com");

        // Cliente adicional con dirección con coma
        Cliente cExtra = new Cliente();
        cExtra.setDni(99991111);
        cExtra.setNombre("Lucía");
        cExtra.setApellidos("Ramírez");
        cExtra.setEdad(32);
        cExtra.setDireccion("Avenida del Ejemplo 45, Valencia");
        cExtra.setTelefono("611111111");
        cExtra.setEmail("lucia.ramirez@ejemplo.com");

        Cuenta cuentaExtra = new Cuenta();
        cuentaExtra.setIBAN("ES0000000000000000000001");
        cuentaExtra.setNumerocuenta(888888);
        cuentaExtra.setFechaCreacion(new Date());
        cuentaExtra.setSaldo(8000); // Alto saldo

        cuentaExtra.addCliente(cExtra);

        em.persist(cExtra);
        em.persist(cuentaExtra);

        // Crear una cuenta de destino para recibir la transferencia
        Cuenta cuentaReceptora = new Cuenta();
        cuentaReceptora.setIBAN("DEST0000000000000000001");
        cuentaReceptora.setNumerocuenta(123987);
        cuentaReceptora.setFechaCreacion(new Date());
        cuentaReceptora.setSaldo(2000);
        em.persist(cuentaReceptora);

        // Crear la transferencia (más de 500€, fecha actual)
        Transferencia tLucia = new Transferencia();
        tLucia.setCodigo_numerico(100);
        tLucia.setFecha(new Date());
        tLucia.setHora(new Date());
        tLucia.setCantidad(750.0);
        tLucia.setTipo("transferencia");
        tLucia.setIban(cuentaExtra); // cuenta de Lucía como emisor
        tLucia.setiban_receptor(cuentaReceptora);

        em.persist(tLucia);

        // Actualizamos saldos
        cuentaExtra.setSaldo((long) (cuentaExtra.getSaldo() - tLucia.getCantidad()));
        cuentaReceptora.setSaldo((long) (cuentaReceptora.getSaldo() + tLucia.getCantidad()));

        em.merge(cuentaExtra);
        em.merge(cuentaReceptora);

        trans.begin();
        try {
            em.persist(cuenta1);
            em.persist(cuenta2);
            em.persist(cuenta3);
            em.persist(cuenta4);
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
        Ingreso deposito = new Ingreso();
        deposito.setCodigo_numerico(1);
        deposito.setFecha(new Date());
        deposito.setHora(new Date());
        deposito.setCantidad(500);
        deposito.setIban(cuenta1);
        deposito.setTipo("ingreso");
        deposito.setCodigoSucursal(o1);

        // 2. Cash withdrawal
        Retirada retirada = new Retirada();
        retirada.setCodigo_numerico(2);
        retirada.setFecha(new Date());
        retirada.setHora(new Date());
        retirada.setCantidad(200);
        retirada.setIban(cuenta2);
        retirada.setTipo("retirada");
        retirada.setOficina(o2);
        // 3. Transfer between accounts
        Transferencia transferencia = new Transferencia();
        transferencia.setCodigo_numerico(3);
        transferencia.setFecha(new Date());
        transferencia.setHora(new Date());
        transferencia.setCantidad(300);
        transferencia.setIban(cuenta1);
        transferencia.setTipo("transferencia");
        transferencia.setiban_receptor(cuenta2);

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

            // Query to database
            // 1. Obtener el saldo medio de las cuentas por ciudad
            // JPQL
            List<Object[]> mediasPorCiudad = em.createQuery(
                    // Seleccionamos dos columnas: la ciudad extraída y el promedio de saldo
                    "SELECT " +
                    // ======= COLUMNA 1: ciudad extraída =======
                            "  TRIM( " + // Quita espacios al inicio/fin
                            "    SUBSTRING( cli.direccion, " + // Toma subcadena de 'direccion' a partir de…
                            "      (CASE " +
                            "         WHEN LOCATE(',', cli.direccion, LOCATE(',', cli.direccion) + 1) > 0 " +
                            "           THEN LOCATE(',', cli.direccion, LOCATE(',', cli.direccion) + 1)" +
                            "         WHEN LOCATE(',', cli.direccion) > 0 " +
                            "           THEN LOCATE(',', cli.direccion)" +
                            "         ELSE 0 " +
                            "       END) + 1 " + // …la posición resultante +1
                            "    )" +
                            "  ), " +
                            // ======= COLUMNA 2: promedio de saldo =======
                            "  AVG(ct.saldo) " +
                            "FROM Cliente cli " + // Entidad Cliente
                            "  JOIN cli.cuentas ct " + // Relación a Cuenta
                            // Agrupamos por la misma expresión de ciudad
                            "GROUP BY " +
                            "  TRIM( " +
                            "    SUBSTRING( cli.direccion, " +
                            "      (CASE " +
                            "         WHEN LOCATE(',', cli.direccion, LOCATE(',', cli.direccion) + 1) > 0 " +
                            "           THEN LOCATE(',', cli.direccion, LOCATE(',', cli.direccion) + 1)" +
                            "         WHEN LOCATE(',', cli.direccion) > 0 " +
                            "           THEN LOCATE(',', cli.direccion)" +
                            "         ELSE 0 " +
                            "       END) + 1 " +
                            "    )" +
                            "  ) " +
                            // Orden descendente por el promedio calculado
                            "ORDER BY AVG(ct.saldo) DESC",
                    Object[].class).getResultList();

            System.out.println("Resultados JPQL:");
            for (Object[] fila : mediasPorCiudad) {
                System.out.printf("Ciudad: %s → Saldo medio: %.2f%n",
                        fila[0], fila[1]);
            }

            // Criteria API
            // 1. Obtenemos el CriteriaBuilder y creamos un CriteriaQuery que devuelva
            // Object[]
            CriteriaBuilder cb = em.getCriteriaBuilder();
            CriteriaQuery<Object[]> cq = cb.createQuery(Object[].class);

            // 2. Definimos la raíz de la consulta sobre Cliente
            Root<Cliente> cliente = cq.from(Cliente.class);

            // 3. Hacemos el join con Cuenta
            Join<Cliente, Cuenta> cuentas = cliente.join("cuentas");

            // 4. Expresiones de selección:
            // a) ciudad = campo direccion tal cual
            Expression<String> ciudadExpr = cliente.get("direccion");
            // b) promedio de saldo
            Expression<Double> avgSaldo = cb.avg(cuentas.get("saldo"));

            // 5. Construimos SELECT, GROUP BY y ORDER BY
            cq.multiselect(ciudadExpr, avgSaldo)
                    .groupBy(ciudadExpr)
                    .orderBy(cb.desc(avgSaldo));

            // 6. Ejecutamos y procesamos resultados
            List<Object[]> resultados = em.createQuery(cq).getResultList();
            System.out.println("Resultados Criteria API (sin parseo de comas):");
            for (Object[] fila : resultados) {
                String ciudad = (String) fila[0];
                Double saldoMedio = (Double) fila[1];
                System.out.printf("Ciudad: %s → Saldo medio: %.2f%n", ciudad, saldoMedio);
            }

            // SQL Nativo
            @SuppressWarnings("unchecked")
            // Ejecutar consulta SQL nativa para calcular el saldo medio por ciudad,
            // extrayendo la ciudad de 'direccion' tras la última coma (o toda la cadena si
            // no hay comas)
            List<Object[]> resultadosNativo = em.createNativeQuery(
                    // Iniciamos el SELECT con un CASE para extraer la ciudad
                    "SELECT " +
                            "  CASE " +
                            "    WHEN INSTR(cli.direccion, ',') > 0 " +
                            // Si existe al menos una coma, usamos INSTR con parámetro -1 para la última
                            // coma,
                            // y SUBSTR + LTRIM para obtener y recortar lo que va después
                            "    THEN LTRIM(SUBSTR(cli.direccion, INSTR(cli.direccion, ',', -1) + 1)) " +
                            // Si no hay coma, tomamos la dirección completa y aplicamos TRIM para recortar
                            // espacios
                            "    ELSE TRIM(cli.direccion) " +
                            "  END AS ciudad, " + // Alias para la columna ciudad
                            // Calculamos el promedio de saldo de las cuentas
                            "  AVG(c.saldo) AS SaldoMedio " + // Alias para la columna de promedio
                            "FROM Cliente cli " +
                            // Join con la tabla intermedia que relaciona clientes y cuentas
                            "JOIN clientes_cuentas cc ON cli.dni = cc.cliente_dni " +
                            // Join con la tabla Cuenta para acceder al campo 'saldo'
                            "JOIN Cuenta c           ON cc.cuenta_id = c.iban " +
                            // Agrupamos por la misma expresión CASE para ciudad
                            "GROUP BY " +
                            "  CASE " +
                            "    WHEN INSTR(cli.direccion, ',') > 0 " +
                            "    THEN LTRIM(SUBSTR(cli.direccion, INSTR(cli.direccion, ',', -1) + 1)) " +
                            "    ELSE TRIM(cli.direccion) " +
                            "  END " +
                            // Ordenamos los resultados de mayor a menor saldo medio
                            "ORDER BY SaldoMedio DESC")
                    .getResultList();

            System.out.println("Resultados SQL nativo:");
            for (Object[] fila : resultadosNativo) {
                String ciudad = (String) fila[0];
                Number saldoMedio = (Number) fila[1];
                System.out.printf("Ciudad=%s → Saldo medio=%.2f%n",
                        ciudad, saldoMedio.doubleValue());
            }

        } catch (PersistenceException e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            System.out.println("ERROR persistiendo operaciones: " + e.getMessage());
            e.printStackTrace();
        }

        try {
            Date fechaLimite = new Date(System.currentTimeMillis() - 90L * 24 * 60 * 60 * 1000); // hace 3 meses
            // JPQL
            List<Cliente> clientesTransferencias = em.createQuery(
                    "SELECT DISTINCT cli " +
                            "FROM Cliente cli " +
                            "JOIN cli.cuentas c " +
                            "JOIN c.operaciones op " +
                            "WHERE TYPE(op) = Transferencia " +
                            "  AND op.cantidad > 500 " +
                            "  AND op.fecha >= :fechaLimite",
                    Cliente.class).setParameter("fechaLimite", fechaLimite)
                    .getResultList();

            System.out.println("Clientes con transferencias > 500 € en los últimos 3 meses (JPQL):");
            for (Cliente c : clientesTransferencias) {
                System.out.println(c);
            }

            // Criteria API
            CriteriaBuilder cb = em.getCriteriaBuilder();
            CriteriaQuery<Cliente> cq = cb.createQuery(Cliente.class);
            Root<Cliente> rootCliente = cq.from(Cliente.class);
            Join<Cliente, Cuenta> joinCuenta = rootCliente.join("cuentas");
            Join<Cuenta, OperacionBancaria> joinOperacion = joinCuenta.join("operaciones");

            // Filtro por tipo Transferencia (usando discriminador "tipo")
            cq.select(rootCliente).distinct(true)
                    .where(
                            cb.and(
                                    cb.equal(joinOperacion.get("tipo"), "transferencia"),
                                    cb.greaterThan(joinOperacion.get("cantidad"), 500.0),
                                    cb.greaterThanOrEqualTo(joinOperacion.get("fecha"), fechaLimite)));

            List<Cliente> resultado = em.createQuery(cq).getResultList();

            System.out.println("Resultado Criteria API (transferencias >500 € en últimos 3 meses):");
            for (Cliente c : resultado) {
                System.out.println(c);
            }

            // SQL Nativo
            @SuppressWarnings("unchecked")
            List<Cliente> clientesSQLNativo = em.createNativeQuery(
                    "SELECT DISTINCT cli.* " +
                            "FROM Cliente cli " +
                            "JOIN clientes_cuentas cc ON cli.dni = cc.cliente_dni " +
                            "JOIN Cuenta c ON cc.cuenta_id = c.iban " +
                            "JOIN OPERACION o ON o.iban_iban = c.iban " +
                            "JOIN Transferencia t ON t.codigo_numerico = o.codigo_numerico AND t.iban_iban = o.iban_iban "
                            +
                            "WHERE o.cantidad > 500 AND o.fecha >= ?",
                    Cliente.class // <-- Esto es lo que permite que te devuelva objetos Cliente directamente
            ).setParameter(1, fechaLimite)
                    .getResultList();

            System.out.println("Resultado SQL nativo (clientes con transferencia >500 €):");
            for (Cliente c : clientesSQLNativo) {
                System.out.println(c);
            }

        } catch (PersistenceException e) {
            if (trans.isActive()) {
                trans.rollback();
            }
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