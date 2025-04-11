package uni;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.ManyToMany;
import javax.persistence.CascadeType;
import javax.persistence.OneToMany;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

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
