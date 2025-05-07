package uni;

import java.util.Date;
import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "Cuenta")
@Inheritance(strategy = InheritanceType.JOINED)
public class Cuenta {

    @Id
    @Column(name = "iban", nullable = false)
    private String iban;

    @Column(name = "numero_cuenta", nullable = false)
    private int numero_cuenta;

    @Column(name = "fecha_creacion", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date fecha_creacion;

    @Column(name = "saldo", nullable = false)
    private long saldo;

    @ManyToMany(mappedBy = "cuentas", cascade = { CascadeType.PERSIST })
    private Set<Cliente> clientes = new HashSet<>();

    @OneToMany(mappedBy = "iban")
    private Set<OperacionBancaria> operaciones = new HashSet<>();

    @OneToMany(mappedBy = "iban_receptor")
    private Set<Transferencia> transferencias = new HashSet<>();

    // Constructor vacío requerido por JPA
    public Cuenta() {
    }

    // Constructor completo
    public Cuenta(String iban, int numero_cuenta, Date fecha_creacion, long saldo) {
        this.iban = iban;
        this.numero_cuenta = numero_cuenta;
        this.fecha_creacion = fecha_creacion;
        this.saldo = saldo;
    }

    // Getters y setters
    public String getIBAN() {
        return iban;
    }

    public void setIBAN(String iban) {
        this.iban = iban;
    }

    public int getNumerocuenta() {
        return numero_cuenta;
    }

    public void setNumerocuenta(int numero_cuenta) {
        this.numero_cuenta = numero_cuenta;
    }

    public Date getFechaCreacion() {
        return fecha_creacion;
    }

    public void setFechaCreacion(Date fecha_creacion) {
        this.fecha_creacion = fecha_creacion;
    }

    public long getSaldo() {
        return saldo;
    }

    public void setSaldo(long saldo) {
        this.saldo = saldo;
    }

    public Set<Cliente> getClientes() {
        return clientes;
    }

    public void setClientes(Set<Cliente> clientes) {
        this.clientes = clientes;
    }

    public Set<OperacionBancaria> getOperaciones() {
        return operaciones;
    }

    public void setOperaciones(Set<OperacionBancaria> operaciones) {
        this.operaciones = operaciones;
    }

    // Métodos utilitarios
    public void addCliente(Cliente cliente) {
        clientes.add(cliente);
        cliente.getCuentas().add(this);
    }

    public void removeCliente(Cliente cliente) {
        clientes.remove(cliente);
        cliente.getCuentas().remove(this);
    }

    public void addOperacion(OperacionBancaria op) {
        operaciones.add(op);
        op.setIban(this);
    }

    public void removeOperacion(OperacionBancaria op) {
        operaciones.remove(op);
        op.setIban(null);
    }

    @Override
    public String toString() {
        String clientesStr = clientes.stream()
                .map(cliente -> cliente.getDni().toString())
                .reduce((a, b) -> a + ", " + b)
                .orElse("");

        String operacionesStr = operaciones.stream()
                .map(op -> "{codigo=" + op.getCodigo_numerico() +
                        ", emisor=" + (op.getIban() != null ? op.getIban().getIBAN() : "null") + "}")
                .reduce((a, b) -> a + ", " + b)
                .orElse("");

        String transferenciasStr = transferencias.stream()
                .map(tf -> "{codigo=" + tf.getCodigo_numerico() +
                        ", emisor=" + (tf.getIban() != null ? tf.getIban() : "null") + "}")
                .reduce((a, b) -> a + ", " + b)
                .orElse("");

        return "Cuenta{" +
                "iban='" + iban + '\'' +
                ", numero_cuenta=" + numero_cuenta +
                ", fecha_creacion=" + fecha_creacion +
                ", saldo=" + saldo +
                ", clientes=[" + clientesStr + "]" +
                ", operaciones=[" + operacionesStr + "]" +
                ", transferencias_recibidas=[" + transferenciasStr + "]" +
                '}';
    }

}
