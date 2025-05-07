package uni;

import java.util.ArrayList;
import java.util.List;
import java.util.Date;
import javax.persistence.*;




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

    @ManyToMany(mappedBy = "Cuentas")
    private List<Cliente> Clientes = new ArrayList<>();
   

    @OneToMany(mappedBy = "cuentaOrigen")
    private List<Operacion> operaciones = new ArrayList<>();

    @OneToMany(mappedBy = "cuentaDestino")
    private List<Transferencia> transferencias = new ArrayList<>();

    // Constructor vacío requerido por JPA
    public Cuenta() {
    }

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

    public List<Cliente> getClientes() {
        return Clientes;
    }

    public void setClientes(List<Cliente> clientes) {
        this.Clientes = clientes;
    }

    public List<Operacion> getOperaciones() {
        return operaciones;
    }

    public void setOperaciones(List<Operacion> operaciones) {
        this.operaciones = operaciones;
    }

    public List<Transferencia> getTransferencias() {
        return transferencias;
    }

    public void setTransferencias(List<Transferencia> transferencias) {
        this.transferencias = transferencias;
    }

    // Métodos utilitarios

    public void addCliente(Cliente cliente) {
        Clientes.add(cliente);
        cliente.getCuentas().add(this);
    }

    public void removeCliente(Cliente cliente) {
        Clientes.remove(cliente);
        cliente.getCuentas().remove(this);
    }

    public void addOperacion(Operacion op) {
        operaciones.add(op);
        op.setCuentaOrigen(this);
    }

    public void removeOperacion(Transferencia tr) {
        transferencias.remove(tr);
        tr.setCuentaOrigen(null);
    }

    public void addTransferencia(Transferencia tr) {
        operaciones.add(tr);
        tr.setCuentaDestino(this);
    }

    public void removeTransferencia(Transferencia tr) {
        operaciones.remove(tr);
        tr.setCuentaDestino(null);
    }

    @Override
    public String toString() {
        return "Cuenta{" +
                "IBAN='" + IBAN + '\'' +
                ", Numerocuenta=" + Numerocuenta +
                ", FechaCreacion=" + FechaCreacion +
                ", Saldo=" + Saldo +
                '}';
    }
    
}
