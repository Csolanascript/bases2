package uni;

import java.io.Serializable;
import java.util.Objects;

public class OperacionPK implements Serializable {
    private int codigoOperacion;
    private String cuentaOrigen; // Cambiado de String IBAN a Cuenta cuentaOrigen

    public OperacionPK() {
    }

    public OperacionPK(int codigoOperacion, String cuentaOrigen) {
        this.codigoOperacion = codigoOperacion;
        this.cuentaOrigen = cuentaOrigen;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        OperacionPK that = (OperacionPK) o;
        return codigoOperacion == that.codigoOperacion && 
               Objects.equals(cuentaOrigen, that.cuentaOrigen);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codigoOperacion, cuentaOrigen);
    }
}