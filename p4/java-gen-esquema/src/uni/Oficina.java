package uni;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "OFICINA")
public class Oficina {
    
    @Id
    @Column(name = "CODIGO_OFICINA")
    private String codigoOficina; // 4 dígitos
    
    @Column(name = "DIRECCION")
    private String direccion;
    
    @Column(name = "TELEFONO")
    private String telefono;
    
    @OneToMany(mappedBy = "oficina")  // Change from "Oficina" to "oficina"
    private List<OperacionEfectivo> operaciones = new ArrayList<>();
    
    @OneToMany(mappedBy = "oficina")  // Change from "Oficina" to field name in CuentaCorriente
    private List<CuentaCorriente> cuentas = new ArrayList<>();
    // No-arg constructor required by JPA
    public Oficina() {
    }
    
    public Oficina(String codigoOficina, String direccion, String telefono) {
        this.codigoOficina = codigoOficina;
        this.direccion = direccion;
        this.telefono = telefono;
    }

	
    public String getCodigoOficina() {
        return codigoOficina;
    }

    public void setCodigoOficina(String codigoOficina) {
        this.codigoOficina = codigoOficina;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public List<OperacionEfectivo> getOperaciones() {
        return operaciones;
    }

    public void setOperaciones(List<OperacionEfectivo> operaciones) {
        this.operaciones = operaciones;
    }

    @Override
    public String toString() {
        return "Oficina{" +
               "codigoOficina='" + codigoOficina + '\'' +
               ", direccion='" + direccion + '\'' +
               ", telefono='" + telefono + '\'' +
               '}';
    }
}