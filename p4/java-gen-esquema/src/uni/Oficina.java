package uni;

import java.util.ArrayList;
import java.util.List;

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

    public List<CuentaCorriente> getCuentas() {
        return cuentas;
    }

    public void setCuentas(List<CuentaCorriente> cuentas) {
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
        StringBuilder cuentasStr = new StringBuilder();
        for (CuentaCorriente cuenta : cuentas) {
            cuentasStr.append(cuenta.getIBAN()).append(", ");
        }
        if (!cuentas.isEmpty()) {
            cuentasStr.setLength(cuentasStr.length() - 2); // quitar última coma
        }
    
        StringBuilder operacionesStr = new StringBuilder();
        for (OperacionEfectivo op : operaciones) {
            String ibanEmisora = (op.getCuentaOrigen() != null) ? op.getCuentaOrigen().getIBAN() : "null";
            operacionesStr.append("[Codigo=").append(op.getCodigoOperacion())
                          .append(", CuentaOrigen=").append(ibanEmisora)
                          .append("], ");
        }
        if (!operaciones.isEmpty()) {
            operacionesStr.setLength(operacionesStr.length() - 2);
        }
    
        return "Oficina{" +
               "codigoOficina='" + codigoOficina + '\'' +
               ", direccion='" + direccion + '\'' +
               ", telefono='" + telefono + '\'' +
               ", cuentas=[" + cuentasStr +
               "], operaciones=[" + operacionesStr +
               "]" +
               '}';
    }
    
}