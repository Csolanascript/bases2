import java.util.*;

public class Model {

    public static class ClienteUDT {
        private String nombre;
        private String apellidos;
        private int edad;
        private String telefono;
        private String email;
        private String direccion;
        private String dni;
        private List<CuentaUDT> cuentas = new ArrayList<>();

        public ClienteUDT(String nombre, String apellidos, int edad, String telefono, String email, String direccion, String dni) {
            this.nombre = nombre;
            this.apellidos = apellidos;
            this.edad = edad;
            this.telefono = telefono;
            this.email = email;
            this.direccion = direccion;
            this.dni = dni;
        }

        public List<CuentaUDT> getCuentas() {
            return cuentas;
        }

        @Override
        public String toString() {
            return "Cliente [" + nombre + " " + apellidos + ", dni=" + dni + "]";
        }
    }

    public static class CuentaUDT {
        protected String numero_cuenta;
        protected String iban;
        protected double saldo;
        protected Date fecha_creacion;
        protected List<ClienteUDT> clientes = new ArrayList<>();
        protected List<OperacionBancariaUDT> operaciones = new ArrayList<>();

        public CuentaUDT(String numero_cuenta, String iban, double saldo, Date fecha_creacion) {
            this.numero_cuenta = numero_cuenta;
            this.iban = iban;
            this.saldo = saldo;
            this.fecha_creacion = fecha_creacion;
        }

        public List<OperacionBancariaUDT> getOperaciones() {
            return operaciones;
        }

        @Override
        public String toString() {
            return "Cuenta [iban=" + iban + ", saldo=" + saldo + "]";
        }
    }

    public static class CuentaCorrienteUDT extends CuentaUDT {
        private double limite_credito;
        private SucursalUDT sucursal;

        public CuentaCorrienteUDT(String numero_cuenta, String iban, double saldo, Date fecha_creacion, double limite_credito, SucursalUDT sucursal) {
            super(numero_cuenta, iban, saldo, fecha_creacion);
            this.limite_credito = limite_credito;
            this.sucursal = sucursal;
        }

        @Override
        public String toString() {
            return super.toString() + " [Cuenta Corriente, límite=" + limite_credito + ", sucursal=" + sucursal + "]";
        }
    }

    public static class CuentaAhorroUDT extends CuentaUDT {
        private double interes;

        public CuentaAhorroUDT(String numero_cuenta, String iban, double saldo, Date fecha_creacion, double interes) {
            super(numero_cuenta, iban, saldo, fecha_creacion);
            this.interes = interes;
        }

        @Override
        public String toString() {
            return super.toString() + " [Cuenta Ahorro, interés=" + interes + "]";
        }
    }

    public static class SucursalUDT {
        private int codigo_sucursal;
        private String direccion;
        private String telefono;

        public SucursalUDT(int codigo_sucursal, String direccion, String telefono) {
            this.codigo_sucursal = codigo_sucursal;
            this.direccion = direccion;
            this.telefono = telefono;
        }

        @Override
        public String toString() {
            return "Sucursal [codigo=" + codigo_sucursal + ", dirección=" + direccion + "]";
        }
    }

    public static class OperacionBancariaUDT {
        protected int codigo_numerico;
        protected Date fecha;
        protected double cantidad;
        protected String descripcion;
        protected CuentaUDT cuenta;
        protected SucursalUDT sucursal;

        public OperacionBancariaUDT(int codigo_numerico, Date fecha, double cantidad, String descripcion, CuentaUDT cuenta, SucursalUDT sucursal) {
            this.codigo_numerico = codigo_numerico;
            this.fecha = fecha;
            this.cantidad = cantidad;
            this.descripcion = descripcion;
            this.cuenta = cuenta;
            this.sucursal = sucursal;
        }
    }

    public static class TransferenciaUDT extends OperacionBancariaUDT {
        private CuentaUDT cuentaReceptora;

        public TransferenciaUDT(int codigo_numerico, Date fecha, double cantidad, String descripcion, CuentaUDT cuenta, CuentaUDT cuentaReceptora) {
            super(codigo_numerico, fecha, cantidad, descripcion, cuenta, null);
            this.cuentaReceptora = cuentaReceptora;
        }
    }

    public static class RetiradaUDT extends OperacionBancariaUDT {
        public RetiradaUDT(int codigo_numerico, Date fecha, double cantidad, String descripcion, CuentaUDT cuenta, SucursalUDT sucursal) {
            super(codigo_numerico, fecha, cantidad, descripcion, cuenta, sucursal);
        }
    }

    public static class IngresoUDT extends OperacionBancariaUDT {
        public IngresoUDT(int codigo_numerico, Date fecha, double cantidad, String descripcion, CuentaUDT cuenta, SucursalUDT sucursal) {
            super(codigo_numerico, fecha, cantidad, descripcion, cuenta, sucursal);
        }
    }
}
