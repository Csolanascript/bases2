package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "Retirada")
public class Retirada extends OperacionBancaria {
    @ManyToOne(optional = false)
    private Sucursal codigoSucursal;
    
    // Constructors
    public Retirada() {
        super();
    }
    
    
    public Sucursal getOficina() {
        return codigoSucursal;
    }
    
    public void setOficina(Sucursal codigoSucursal) {
        this.codigoSucursal = codigoSucursal;
    }
    
    @Override
    public String toString() {
        return super.toString() + " Retirada [Sucursal=" + codigoSucursal + "]";
    }
}