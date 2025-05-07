package uni;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;


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
        return super.toString() + ", codigo_sucursal=" + codigo_sucursal;
    }
	
}

