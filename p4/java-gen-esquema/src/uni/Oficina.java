package uni;

import java.util.Set;
import java.util.HashSet;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "Oficina")
public class Oficina {
    
    @Id
    @Column(name = "CODIGO_OFICINA")
    private String codigoOficina; // 4 dígitos
    
    @Column(name = "DIRECCION")
    private String direccion;
    
    @Column(name = "TELEFONO")
    private String telefono;
    
    @OneToMany(mappedBy = "oficina")  // Change from "Oficina" to "oficina"
    private Set<OperacionEfectivo> operaciones = new HashSet<>();
    
    @OneToMany(mappedBy = "oficina")  // Change from "Oficina" to field name in CuentaCorriente
    private Set<CuentaCorriente> cuentas = new HashSet<>();

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

    public Set<OperacionEfectivo> getOperaciones() {
        return operaciones;
    }

    public void setOperaciones(Set<OperacionEfectivo> operaciones) {
        this.operaciones = operaciones;
    }

    public Set<CuentaCorriente> getCuentas() {
        return cuentas;
    }

    public void setCuentas(Set<CuentaCorriente> cuentas) {
        this.cuentas = cuentas;
    }

    public void addOperacion(OperacionEfectivo op) {
        operaciones.add(op);
        op.setOficina(this);
    }

    public void removeOperacion(OperacionEfectivo op) {
        operaciones.remove(op);
        op.setOficina(null);
    }

    public void addCuenta(CuentaCorriente cuenta) {
        cuentas.add(cuenta);
        cuenta.setOficina(this);
    }

    public void removeCuenta(CuentaCorriente cuenta) {
        cuentas.remove(cuenta);
        cuenta.setOficina(null);
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