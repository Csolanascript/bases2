package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "OPERACION_EFECTIVO")
public class OperacionEfectivo extends Operacion {
    
    public enum TipoOperacionEfectivo {
        INGRESO, RETIRADA
    }
    
    @Column(name = "TIPO_OPERACION_EFECTIVO", nullable = false)
    @Enumerated(EnumType.STRING)
    private TipoOperacionEfectivo tipoOperacion;
    

    @ManyToOne(optional = false)
    private Oficina oficina;
    
    // Constructors
    public OperacionEfectivo() {
        super();
    }
    
    // Getters and setters
    public TipoOperacionEfectivo getTipoOperacion() {
        return tipoOperacion;
    }
    
    public void setTipoOperacion(TipoOperacionEfectivo tipoOperacion) {
        this.tipoOperacion = tipoOperacion;
    }
    
    public Oficina getOficina() {
        return oficina;
    }
    
    public void setOficina(Oficina oficina) {
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