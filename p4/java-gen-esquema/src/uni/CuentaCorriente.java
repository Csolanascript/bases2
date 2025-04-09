package uni;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.JoinColumn;

import java.util.Date;

@Entity(name = "CuentaCorriente")
public class CuentaCorriente extends Cuenta {
	
    @ManyToOne
    private Oficina oficina;
	
    // Constructor vacío requerido por JPA
    public CuentaCorriente() {}

    // Constructor completo (incluyendo atributos heredados)
    public CuentaCorriente(String IBAN, int numerocuenta, Date fechaCreacion, long saldo, Oficina oficina) {
        super(IBAN, numerocuenta, fechaCreacion, saldo);
        this.oficina = oficina;
    }

    // Getter y Setter para oficina
    public Oficina getOficina() {
        return oficina;
    }

    public void setOficina(Oficina oficina) {
        this.oficina = oficina;
    }

    @Override
    public String toString() {
        return "CuentaCorriente{" +
                "IBAN='" + getIBAN() + '\'' +
                ", numerocuenta=" + getNumerocuenta() +
                ", fechaCreacion=" + getFechaCreacion() +
                ", saldo=" + getSaldo() +
                ", oficina=" + oficina +
                '}';
    }
	
}

