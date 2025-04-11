package uni;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name = "OPERACION")
@Inheritance(strategy = InheritanceType.JOINED)
public abstract class OperacionBancaria {
    
    @Id
    @Column(name = "codigo_numerico")
    private int codigo_numerico;
    
    @Temporal(TemporalType.DATE)
    @Column(name = "fecha", nullable = false)
    private Date fecha;

    @Temporal(TemporalType.TIME)
    @Column(name = "hora", nullable = false)
    private Date hora;

    
    @Column(name = "cantidad", nullable = false)
    private double cantidad;
    
    @ManyToOne(optional = false)
    private Cuenta iban;
    
   
    
    // Constructors
    public OperacionBancaria() {
    }
    
    // Getters and setters
    public int getCodigoOperacion() {
        return codigoOperacion;
    }

    public void setCodigoOperacion(int codigoOperacion) {
        this.codigoOperacion = codigoOperacion;
    }

    public Date getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(Date fechaHora) {
        this.fechaHora = fechaHora;
    }

    public double getCantidad() {
        return cantidad;
    }

    public void setCantidad(double cantidad) {
        this.cantidad = cantidad;
    }

    public Cuenta getCuentaOrigen() {
        return cuentaOrigen;
    }

    public void setCuentaOrigen(Cuenta cuentaOrigen) {
        this.cuentaOrigen = cuentaOrigen;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    @Override
    public String toString() {
        return "Operación #" + codigoOperacion + 
               "\nFecha: " + fechaHora + 
               "\nCantidad: " + cantidad +
               "\nCuenta origen: " + cuentaOrigen.getIBAN() +
               (descripcion != null ? "\nDescripción: " + descripcion : "");
    }
}