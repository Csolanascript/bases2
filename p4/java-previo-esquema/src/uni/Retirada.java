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
    
    // Getters and setters
    public TipoOperacionEfectivo getTipoOperacion() {
        return tipoOperacion;
    }
    
    public void setTipoOperacion(TipoOperacionEfectivo tipoOperacion) {
        this.tipoOperacion = tipoOperacion;
    }
    
    public Sucursal getOficina() {
        return oficina;
    }
    
    public void setOficina(Sucursal oficina) {
        this.oficina = oficina;
    }
    
    @Override
    public String toString() {
        return "OperacionEfectivo [tipoOperacion=" + tipoOperacion + 
               ", oficina=" + oficina.getCodigoOficina() +
               ", getCodigoOperacion()=" + getCodigoOperacion() +
               ", getFechaHora()=" + getFechaHora() + 
               ", getCantidad()=" + getCantidad() + 
               ", getDescripcion()=" + getDescripcion() + "]";
    }
}