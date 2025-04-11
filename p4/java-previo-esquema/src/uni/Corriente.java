package uni;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.JoinColumn;

import java.util.Date;

@Entity(name = "Corriente")
public class Corriente extends Cuenta {
	
    @ManyToOne
    private Sucursal codigo_sucursal;
	
    // Constructor vacío requerido por JPA
    public Corriente() {}

    // Constructor completo (incluyendo atributos heredados)
    public Corriente(String IBAN, int numerocuenta, Date fechaCreacion, long saldo, Sucursal codigo_sucursal) {
        super(IBAN, numerocuenta, fechaCreacion, saldo);
        this.codigo_sucursal = codigo_sucursal;
    }

    // Getter y Setter para oficina
    public Sucursal getSucursal() {
        return codigo_sucursal;
    }

    public void setSucursal(Sucursal codigo_sucursal) {
        this.codigo_sucursal = codigo_sucursal;
    }

    @Override
    public String toString() {
        return "CuentaCorriente{" +
                "iban='" + getIBAN() + '\'' +
                ", numero_cuenta=" + getNumerocuenta() +
                ", fecha_creacion=" + getFechaCreacion() +
                ", saldo=" + getSaldo() +
                ", codigo_sucursal=" + codigo_sucursal +
                '}';
    }
	
}

