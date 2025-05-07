package uni;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "Retirada")
public class Retirada extends OperacionBancaria {
    @ManyToOne(optional = false)
    private Sucursal codigo_sucursal;
    
    // Constructors
    public Retirada() {
        super();
    }
    
    
    public Sucursal getOficina() {
        return codigo_sucursal;
    }
    
    public void setOficina(Sucursal codigo_sucursal) {
        this.codigo_sucursal = codigo_sucursal;
    }
    
    @Override
    public String toString() {
        return super.toString() + " Retirada [Sucursal=" + codigo_sucursal + "]";
    }
}