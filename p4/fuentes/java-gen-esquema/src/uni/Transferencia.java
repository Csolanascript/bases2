package uni;

import java.util.Date;


import javax.persistence.Entity;

import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "Transferencia")
public class Transferencia extends Operacion {

    @ManyToOne(optional = true) // ¡Importante! No usar optional = false
    private Cuenta cuentaDestino;

    // Constructors
    public Transferencia() {
    }

    public Transferencia(int codigoOperacion, Date fechaHora, double cantidad, Cuenta cuentaOrigen,
            String descripcion) {
        super(codigoOperacion, fechaHora, cantidad, cuentaOrigen, descripcion);
    }

    // Getters and setters
    public void setCuentaDestino(Cuenta cuentaDestino) {
        this.cuentaDestino = cuentaDestino;
    }

    public Cuenta getCuentaDestino() {
        return cuentaDestino;
    }

    @Override
    public String toString() {
        return "Transferencia {" +
                "CodigoOperacion=" + getCodigoOperacion() +
                ", FechaHora=" + getFechaHora() +
                ", Cantidad=" + getCantidad() +
                (getDescripcion() != null ? ", Descripcion='" + getDescripcion() + '\'' : "") +
                '}';
    }

}
