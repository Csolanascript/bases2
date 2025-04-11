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

    @Id
    @ManyToOne(optional = false)
    private Cuenta iban;

    @Temporal(TemporalType.DATE)
    @Column(name = "fecha", nullable = false)
    private Date fecha;

    @Temporal(TemporalType.TIME)
    @Column(name = "hora", nullable = false)
    private Date hora;

    @Column(name = "cantidad", nullable = false)
    private double cantidad;

    

    // Constructors
    public OperacionBancaria() {
    }

    public OperacionBancaria(int codigo_numerico, Date fecha, Date hora, double cantidad, Cuenta iban) {
        this.codigo_numerico = codigo_numerico;
        this.fecha = fecha;
        this.hora = hora;
        this.cantidad = cantidad;
        this.iban = iban;
    }

    // Getters y Setters

    public int getCodigo_numerico() {
        return codigo_numerico;
    }

    public void setCodigo_numerico(int codigo_numerico) {
        this.codigo_numerico = codigo_numerico;
    }

    public Date getFecha() {
        return fecha;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public Date getHora() {
        return hora;
    }

    public void setHora(Date hora) {
        this.hora = hora;
    }

    public double getCantidad() {
        return cantidad;
    }

    public void setCantidad(double cantidad) {
        this.cantidad = cantidad;
    }

    public Cuenta getIban() {
        return iban;
    }

    public void setIban(Cuenta iban) {
        this.iban = iban;
    }



    @Override
    public String toString() {
        return "OperacionBancaria [codigo_numerico=" + codigo_numerico + ", fecha=" + fecha + ", hora=" + hora
                + ", cantidad=" + cantidad + ", iban=" + iban.getIBAN() + "]";
    }

}