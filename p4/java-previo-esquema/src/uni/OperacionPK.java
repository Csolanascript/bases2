package uni;

import java.io.Serializable;
import java.util.Objects;

public class OperacionPK implements Serializable {
    private int codigo_numerico;   // antes codigoOperacion
    private String iban;           // antes cuentaOrigen

    public OperacionPK() {}
    public OperacionPK(int codigo_numerico, String iban) {
        this.codigo_numerico = codigo_numerico;
        this.iban           = iban;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        OperacionPK that = (OperacionPK) o;
        return codigo_numerico == that.codigo_numerico && 
               Objects.equals(iban, that.iban);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codigo_numerico, iban);
    }
}