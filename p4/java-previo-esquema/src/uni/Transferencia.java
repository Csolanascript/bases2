package uni;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "Transferencia")
public class Transferencia extends OperacionBancaria {

    @ManyToOne(optional = true) // ¡Importante! No usar optional = false
    private Cuenta iban_receptor;

    // Constructors
    public Transferencia() {
    }

    public Transferencia(int codigoOperacion, Date fecha, Date hora, double cantidad, Cuenta iban_receptor) {
        super(codigoOperacion, fecha, hora, cantidad, iban_receptor);
    }

    // Getters and setters
    public void setiban_receptor(Cuenta iban_receptor) {
        this.iban_receptor = iban_receptor;
    }

    public Cuenta getiban_receptor() {
        return iban_receptor;
    }
/*
    @Override
    public String toString() {
        return "Transferencia {" +
                "CodigoOperacion=" + getCodigoOperacion() +
                ", FechaHora=" + getFechaHora() +
                ", Cantidad=" + getCantidad() +
                (getDescripcion() != null ? ", Descripcion='" + getDescripcion() + '\'' : "") +
                '}';
    }*/

}
