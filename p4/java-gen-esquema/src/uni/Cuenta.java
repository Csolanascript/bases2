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
    @Column(name = "IBAN", nullable = false)
    private String IBAN;

    @Column(name = "Numerocuenta", nullable = false)
    private int Numerocuenta;

    @Column(name = "FechaCreacion", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date FechaCreacion;

    @Column(name = "Saldo", nullable = false)
    private long Saldo;

    @ManyToMany(mappedBy = "cuentas", cascade = {CascadeType.PERSIST})
    private Set<Cliente> clientes = new HashSet<>();

    @OneToMany(mappedBy = "cuentaOrigen")
    private Set<Operacion> operaciones = new HashSet<>();

    @OneToMany(mappedBy = "cuentaDestino")
    private Set<Transferencia> transferencias = new HashSet<>();

    // Constructor vacío requerido por JPA
    public Cuenta() {}

    // Constructor completo
    public Cuenta(String IBAN, int numerocuenta, Date fechaCreacion, long saldo) {
        this.IBAN = IBAN;
        this.Numerocuenta = numerocuenta;
        this.FechaCreacion = fechaCreacion;
        this.Saldo = saldo;
    }

    // Getters y setters
    public String getIBAN() {
        return IBAN;
    }

    public void setIBAN(String IBAN) {
        this.IBAN = IBAN;
    }

    public int getNumerocuenta() {
        return Numerocuenta;
    }

    public void setNumerocuenta(int numerocuenta) {
        this.Numerocuenta = numerocuenta;
    }

    public Date getFechaCreacion() {
        return FechaCreacion;
    }

    public void setFechaCreacion(Date fechaCreacion) {
        this.FechaCreacion = fechaCreacion;
    }

    public long getSaldo() {
        return Saldo;
    }

    public void setSaldo(long saldo) {
        this.Saldo = saldo;
    }

    public Set<Cliente> getClientes() {
        return clientes;
    }

    public void setClientes(Set<Cliente> clientes) {
        this.clientes = clientes;
    }

    public Set<Operacion> getOperaciones() {
        return operaciones;
    }

    public void setOperaciones(Set<Operacion> operaciones) {
        this.operaciones = operaciones;
    }

    public Set<Transferencia> getTransferencias() {
        return transferencias;
    }

    public void setTransferencia(Set<Transferencia> transferencias) {
        this.transferencias = transferencias;
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

    public void addOperacion(Operacion op) {
        operaciones.add(op);
        op.setCuentaOrigen(this);
    }

    public void removeOperacion(Operacion op) {
        operaciones.remove(op);
        op.setCuentaOrigen(null);
    }

    public void addTransferencia(Transferencia transferencia) {
        transferencias.add(transferencia);
        transferencia.setCuentaDestino(this);
    }

    public void removeTransferencia(Transferencia transferencia) {
        transferencias.remove(transferencia);
        transferencia.setCuentaDestino(null);
    }


    @Override
    public String toString() {
        return "Cuenta{" +
                "IBAN='" + IBAN + '\'' +
                ", numerocuenta=" + Numerocuenta +
                ", fechaCreacion=" + FechaCreacion +
                ", saldo=" + Saldo +
                '}';
    }
}
