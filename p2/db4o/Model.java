import java.util.Date;

public class Model {

    // Clase que representa el tipo ClienteUDT
    public static class ClienteUDT {
        private int id_cliente;
        private String nombre;
        private String apellidos;
        private int edad;
        private String telefono;
        private String email;
        private String direccion;
        private String dni;

        public ClienteUDT() {
        }

        public ClienteUDT(int id_cliente, String nombre, String apellidos, int edad, String telefono, String email, String direccion, String dni) {
            this.id_cliente = id_cliente;
            this.nombre = nombre;
            this.apellidos = apellidos;
            this.edad = edad;
            this.telefono = telefono;
            this.email = email;
            this.direccion = direccion;
            this.dni = dni;
        }

        public int getId_cliente() {
            return id_cliente;
        }

        public void setId_cliente(int id_cliente) {
            this.id_cliente = id_cliente;
        }

        public String getNombre() {
            return nombre;
        }

        public void setNombre(String nombre) {
            this.nombre = nombre;
        }

        public String getApellidos() {
            return apellidos;
        }

        public void setApellidos(String apellidos) {
            this.apellidos = apellidos;
        }

        public int getEdad() {
            return edad;
        }

        public void setEdad(int edad) {
            this.edad = edad;
        }

        public String getTelefono() {
            return telefono;
        }

        public void setTelefono(String telefono) {
            this.telefono = telefono;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getDireccion() {
            return direccion;
        }

        public void setDireccion(String direccion) {
            this.direccion = direccion;
        }

        public String getDni() {
            return dni;
        }

        public void setDni(String dni) {
            this.dni = dni;
        }

        @Override
        public String toString() {
            return "ClienteUDT [id_cliente=" + id_cliente + ", nombre=" + nombre + ", apellidos=" + apellidos +
                   ", edad=" + edad + ", telefono=" + telefono + ", email=" + email +
                   ", direccion=" + direccion + ", dni=" + dni + "]";
        }
    }

    // Clase base para CuentaUDT
    public static class CuentaUDT {
        private String numero_cuenta;
        private String iban;
        private double saldo;
        private Date fecha_creacion;
        private String tipo_cuenta;

        public CuentaUDT() {
        }

        public CuentaUDT(String numero_cuenta, String iban, double saldo, Date fecha_creacion, String tipo_cuenta) {
            this.numero_cuenta = numero_cuenta;
            this.iban = iban;
            this.saldo = saldo;
            this.fecha_creacion = fecha_creacion;
            this.tipo_cuenta = tipo_cuenta;
        }

        public String getNumero_cuenta() {
            return numero_cuenta;
        }

        public void setNumero_cuenta(String numero_cuenta) {
            this.numero_cuenta = numero_cuenta;
        }

        public String getIban() {
            return iban;
        }

        public void setIban(String iban) {
            this.iban = iban;
        }

        public double getSaldo() {
            return saldo;
        }

        public void setSaldo(double saldo) {
            this.saldo = saldo;
        }

        public Date getFecha_creacion() {
            return fecha_creacion;
        }

        public void setFecha_creacion(Date fecha_creacion) {
            this.fecha_creacion = fecha_creacion;
        }

        public String getTipo_cuenta() {
            return tipo_cuenta;
        }

        public void setTipo_cuenta(String tipo_cuenta) {
            this.tipo_cuenta = tipo_cuenta;
        }

        @Override
        public String toString() {
            return "CuentaUDT [numero_cuenta=" + numero_cuenta + ", iban=" + iban + ", saldo=" + saldo +
                   ", fecha_creacion=" + fecha_creacion + ", tipo_cuenta=" + tipo_cuenta + "]";
        }
    }

    // Clase base para OperacionBancariaUDT
    public static class OperacionBancariaUDT {
        private int id_operacion;
        private Date fecha;
        private double monto;
        private String tipo_operacion;
        private String descripcion;
        private String iban; // Cuenta sobre la que se hace la operación
        private int codigo_sucursal; // Sucursal donde se realiza la operación

        public OperacionBancariaUDT() {
        }

        public OperacionBancariaUDT(int id_operacion, Date fecha, double monto, String tipo_operacion, String descripcion, String iban, int codigo_sucursal) {
            this.id_operacion = id_operacion;
            this.fecha = fecha;
            this.monto = monto;
            this.tipo_operacion = tipo_operacion;
            this.descripcion = descripcion;
            this.iban = iban;
            this.codigo_sucursal = codigo_sucursal;
        }

        public int getId_operacion() {
            return id_operacion;
        }

        public void setId_operacion(int id_operacion) {
            this.id_operacion = id_operacion;
        }

        public Date getFecha() {
            return fecha;
        }

        public void setFecha(Date fecha) {
            this.fecha = fecha;
        }

        public double getMonto() {
            return monto;
        }

        public void setMonto(double monto) {
            this.monto = monto;
        }

        public String getTipo_operacion() {
            return tipo_operacion;
        }

        public void setTipo_operacion(String tipo_operacion) {
            this.tipo_operacion = tipo_operacion;
        }

        public String getDescripcion() {
            return descripcion;
        }

        public void setDescripcion(String descripcion) {
            this.descripcion = descripcion;
        }

        public String getIban() {
            return iban;
        }

        public void setIban(String iban) {
            this.iban = iban;
        }

        public int getCodigo_sucursal() {
            return codigo_sucursal;
        }

        public void setCodigo_sucursal(int codigo_sucursal) {
            this.codigo_sucursal = codigo_sucursal;
        }

        @Override
        public String toString() {
            return "OperacionBancariaUDT [id_operacion=" + id_operacion + ", fecha=" + fecha + ", monto=" + monto +
                   ", tipo_operacion=" + tipo_operacion + ", descripcion=" + descripcion + ", iban=" + iban +
                   ", codigo_sucursal=" + codigo_sucursal + "]";
        }
    }

    // Clase que representa el tipo SucursalUDT
    public static class SucursalUDT {
        private int codigo_sucursal;
        private String direccion;
        private String telefono;

        public SucursalUDT() {
        }

        public SucursalUDT(int codigo_sucursal, String direccion, String telefono) {
            this.codigo_sucursal = codigo_sucursal;
            this.direccion = direccion;
            this.telefono = telefono;
        }

        public int getCodigo_sucursal() {
            return codigo_sucursal;
        }

        public void setCodigo_sucursal(int codigo_sucursal) {
            this.codigo_sucursal = codigo_sucursal;
        }

        public String getDireccion() {
            return direccion;
        }

        public void setDireccion(String direccion) {
            this.direccion = direccion;
        }

        public String getTelefono() {
            return telefono;
        }

        public void setTelefono(String telefono) {
            this.telefono = telefono;
        }

        @Override
        public String toString() {
            return "SucursalUDT [codigo_sucursal=" + codigo_sucursal + ", direccion=" + direccion + ", telefono=" + telefono + "]";
        }
    }

    // TransferenciaUDT (subtipo de OperacionBancariaUDT)
    public static class TransferenciaUDT extends OperacionBancariaUDT {
        private String iban_emisor;
        private String iban_receptor;

        public TransferenciaUDT() {
            super();
        }

        public TransferenciaUDT(int id_operacion, Date fecha, double monto, String tipo_operacion, String descripcion, String iban, int codigo_sucursal, String iban_emisor, String iban_receptor) {
            super(id_operacion, fecha, monto, tipo_operacion, descripcion, iban, codigo_sucursal);
            this.iban_emisor = iban_emisor;
            this.iban_receptor = iban_receptor;
        }

        public String getIban_emisor() {
            return iban_emisor;
        }

        public void setIban_emisor(String iban_emisor) {
            this.iban_emisor = iban_emisor;
        }

        public String getIban_receptor() {
            return iban_receptor;
        }

        public void setIban_receptor(String iban_receptor) {
            this.iban_receptor = iban_receptor;
        }

        @Override
        public String toString() {
            return "TransferenciaUDT [" + super.toString() + ", iban_emisor=" + iban_emisor + ", iban_receptor=" + iban_receptor + "]";
        }
    }

    // RetiradaUDT (subtipo de OperacionBancariaUDT)
    public static class RetiradaUDT extends OperacionBancariaUDT {
        private String metodo_retiro;

        public RetiradaUDT() {
            super();
        }

        public RetiradaUDT(int id_operacion, Date fecha, double monto, String tipo_operacion, String descripcion, String iban, int codigo_sucursal, String metodo_retiro) {
            super(id_operacion, fecha, monto, tipo_operacion, descripcion, iban, codigo_sucursal);
            this.metodo_retiro = metodo_retiro;
        }

        public String getMetodo_retiro() {
            return metodo_retiro;
        }

        public void setMetodo_retiro(String metodo_retiro) {
            this.metodo_retiro = metodo_retiro;
        }

        @Override
        public String toString() {
            return "RetiradaUDT [" + super.toString() + ", metodo_retiro=" + metodo_retiro + "]";
        }
    }

    // IngresoUDT (subtipo de OperacionBancariaUDT)
    public static class IngresoUDT extends OperacionBancariaUDT {
        private String metodo_pago;

        public IngresoUDT() {
            super();
        }

        public IngresoUDT(int id_operacion, Date fecha, double monto, String tipo_operacion, String descripcion, String iban, int codigo_sucursal, String metodo_pago) {
            super(id_operacion, fecha, monto, tipo_operacion, descripcion, iban, codigo_sucursal);
            this.metodo_pago = metodo_pago;
        }

        public String getMetodo_pago() {
            return metodo_pago;
        }

        public void setMetodo_pago(String metodo_pago) {
            this.metodo_pago = metodo_pago;
        }

        @Override
        public String toString() {
            return "IngresoUDT [" + super.toString() + ", metodo_pago=" + metodo_pago + "]";
        }
    }

    // CuentaAhorroUDT (subtipo de CuentaUDT)
    public static class CuentaAhorroUDT extends CuentaUDT {
        private double interes;

        public CuentaAhorroUDT() {
            super();
        }

        public CuentaAhorroUDT(String numero_cuenta, String iban, double saldo, Date fecha_creacion, String tipo_cuenta, double interes) {
            super(numero_cuenta, iban, saldo, fecha_creacion, tipo_cuenta);
            this.interes = interes;
        }

        public double getInteres() {
            return interes;
        }

        public void setInteres(double interes) {
            this.interes = interes;
        }

        @Override
        public String toString() {
            return "CuentaAhorroUDT [" + super.toString() + ", interes=" + interes + "]";
        }
    }

    // CuentaCorrienteUDT (subtipo de CuentaUDT)
    public static class CuentaCorrienteUDT extends CuentaUDT {
        private double limite_credito;

        public CuentaCorrienteUDT() {
            super();
        }

        public CuentaCorrienteUDT(String numero_cuenta, String iban, double saldo, Date fecha_creacion, String tipo_cuenta, double limite_credito) {
            super(numero_cuenta, iban, saldo, fecha_creacion, tipo_cuenta);
            this.limite_credito = limite_credito;
        }

        public double getLimite_credito() {
            return limite_credito;
        }

        public void setLimite_credito(double limite_credito) {
            this.limite_credito = limite_credito;
        }

        @Override
        public String toString() {
            return "CuentaCorrienteUDT [" + super.toString() + ", limite_credito=" + limite_credito + "]";
        }
    }
}
