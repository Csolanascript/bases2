package uni;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.PrimaryKeyJoinColumns;

@Entity
@Table(name = "Ingreso")
@PrimaryKeyJoinColumns({
  @PrimaryKeyJoinColumn(
    name = "codigo_numerico",
    referencedColumnName = "codigo_numerico"
  ),
  @PrimaryKeyJoinColumn(
    name = "iban_iban",
    referencedColumnName = "iban_iban"
  )
})
public class Ingreso extends OperacionBancaria {
    @ManyToOne(optional = false)
    private Sucursal codigo_sucursal;
    
    // Constructors
    public Ingreso() {
        super();
    }
    
    
    public Sucursal getCodigoSucursal() {
        return codigo_sucursal;
    }
    
    public void setCodigoSucursal(Sucursal codigo_sucursal) {
        this.codigo_sucursal = codigo_sucursal;
    }

    
    @Override
    public String toString() {
        return super.toString() + " Ingreso [codigoSucursal=" + codigo_sucursal.getCodigo_sucursal() + "]";
    }
}