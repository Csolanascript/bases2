package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "Ingreso")
public class Ingreso extends OperacionBancaria {
    @ManyToOne(optional = false)
    private Sucursal codigoSucursal;
    
    // Constructors
    public Ingreso() {
        super();
    }
    
    
    public Sucursal getCodigoSucursal() {
        return codigoSucursal;
    }
    
    public void setCodigoSucursal(Sucursal codigoSucursal) {
        this.codigoSucursal = codigoSucursal;
    }
}