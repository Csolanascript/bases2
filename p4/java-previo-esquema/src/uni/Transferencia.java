package uni;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "Transferencia")
public class Transferencia extends OperacionBancaria {

    @ManyToOne(optional = true) // ¡Importante! No usar optional = false
    private Cuenta cuentaDestino;

    // Constructors
    public Transferencia() {
    }

    public Transferencia(int codigoOperacion, Date fecha, Date hora, double cantidad, Cuenta cuentaOrigen) {
        super(codigoOperacion, fecha, hora, cantidad, cuentaOrigen);
    }

    // Getters and setters
    public void setCuentaDestino(Cuenta cuentaDestino) {
        this.cuentaDestino = cuentaDestino;
    }

    public Cuenta getCuentaDestino() {
        return cuentaDestino;
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
