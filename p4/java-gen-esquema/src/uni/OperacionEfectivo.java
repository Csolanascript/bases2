package uni;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "OperacionEfectivo")
public class OperacionEfectivo extends Operacion {    

    @ManyToOne(optional = false)
    private Oficina oficina;
    

    public OperacionEfectivo() {
    }

    // Constructors
    public OperacionEfectivo(int codigoOperacion, Date fechaHora, double cantidad, Cuenta cuentaOrigen, String descripcion) {
        super(codigoOperacion, fechaHora, cantidad, cuentaOrigen, descripcion);
    }
    
    public Oficina getOficina() {
        return oficina;
    }
    
    public void setOficina(Oficina oficina) {
        this.oficina = oficina;
    }
    
    @Override
    public String toString() {
        String cuentaOrigenIBAN = (getCuentaOrigen() != null) ? getCuentaOrigen().getIBAN() : "null";
        String oficinaCodigo = (oficina != null) ? oficina.getCodigoOficina() : "null";
    
        return "OperacionEfectivo {" +
               "CodigoOperacion=" + getCodigoOperacion() +
               ", FechaHora=" + getFechaHora() +
               ", Cantidad=" + getCantidad() +
               ", CuentaOrigen=" + cuentaOrigenIBAN +
               ", Oficina=" + oficinaCodigo +
               (getDescripcion() != null ? ", Descripcion='" + getDescripcion() + '\'' : "") +
               '}';
    }
    
}