package uni;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;


@Entity
@Table(name = "CuentaAhorro")
public class CuentaAhorro extends Cuenta {

    @Column(name = "Interes", nullable = false)
    private double interes;

    public CuentaAhorro() {}

    public CuentaAhorro(String IBAN, int numerocuenta, Date fechaCreacion, long saldo, double interes) {
        super(IBAN, numerocuenta, fechaCreacion, saldo);
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
