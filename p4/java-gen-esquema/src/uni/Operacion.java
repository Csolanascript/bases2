package uni;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name = "Operacion")
@Inheritance(strategy = InheritanceType.JOINED)
@IdClass(OperacionPK.class)
public abstract class Operacion {
    
    @Id
    @Column(name = "CODIGO_OPERACION")
    private int codigoOperacion;
    
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "FECHA_HORA", nullable = false)
    private Date fechaHora;
    
    @Column(name = "CANTIDAD", nullable = false)
    private double cantidad;

    @Id
    @ManyToOne
    @JoinColumn(name = "CUENTA_ORIGEN_IBAN", nullable = false)
    private Cuenta cuentaOrigen;
    
    @Column(name = "DESCRIPCION")
    private String descripcion;



    
    // Constructors
    public Operacion() {
    }

    public Operacion(int codigoOperacion, Date fechaHora, double cantidad, Cuenta cuentaOrigen, String descripcion) {
        this.codigoOperacion = codigoOperacion;
        this.fechaHora = fechaHora;
        this.cantidad = cantidad;
        this.descripcion = descripcion;
        setCuentaOrigen(cuentaOrigen); // Para que también asigne el IBAN
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
        return "Operación: " + codigoOperacion + 
               "\nFecha: " + fechaHora + 
               "\nCantidad: " + cantidad +
               (descripcion != null ? "\nDescripción: " + descripcion : "");
    }
    
}



