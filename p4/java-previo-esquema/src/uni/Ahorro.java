package uni;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;




@Entity
@Table(name = "Ahorro")
public class Ahorro extends Cuenta {

    @Column(name = "interes", nullable = false)
    private double interes;

    public Ahorro() {}

    public Ahorro(String iban, int numerocuenta, Date fechaCreacion, long saldo, double interes) {
        super(iban, numerocuenta, fechaCreacion, saldo);
        this.interes = interes;
    }

    public double getInteres() {
        return interes;
    }

    public void setInteres(double interes) {
        this.interes = interes;
    }

    @Override
    public String toString() {
        return super.toString() + ", interes=" + interes;
    }
}
