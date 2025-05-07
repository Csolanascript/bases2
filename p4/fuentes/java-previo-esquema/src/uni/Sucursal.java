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
public class Sucursal {
    
    @Id
    @Column(name = "codigo_sucursal")
    private int codigo_sucursal; // 4 dígitos
    
    @Column(name = "direccion")
    private String direccion;
    
    @Column(name = "telefono")
    private String telefono;
    
    @OneToMany(mappedBy = "codigo_sucursal")  
    private List<Retirada> retiradas = new ArrayList<>();

    @OneToMany(mappedBy = "codigo_sucursal")  
    private List<Ingreso> ingresos = new ArrayList<>();
    
    @OneToMany(mappedBy = "codigo_sucursal")  
    private List<Corriente> cuentas = new ArrayList<>();
    
    public Sucursal() {
    }
    
    public Sucursal(int codigo_sucursal, String direccion, String telefono) {
        this.codigo_sucursal = codigo_sucursal;
        this.direccion = direccion;
        this.telefono = telefono;
    }

	
    public int getCodigo_sucursal() {
        return codigo_sucursal;
    }

    public void setCodigo_sucursal(int codigo_sucursal) {
        this.codigo_sucursal = codigo_sucursal;
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

    public List<Retirada> getRetiradas() {
        return retiradas;
    }

    public void setRetiradas(List<Retirada> retiradas) {
        this.retiradas = retiradas;
    }

    public List<Ingreso> getIngresos() {
        return ingresos;
    }

    public void setIngresos(List<Ingreso> ingresos) {
        this.ingresos = ingresos;
    }

    public List<Corriente> getCuentas() {
        return cuentas;
    }

    public void setCuentas(List<Corriente> cuentas) {
        this.cuentas = cuentas;
    }
    public void addCuenta(Corriente cuenta) {
        this.cuentas.add(cuenta);
        cuenta.setSucursal(this);
    }


    @Override
    public String toString() {
        return "Sucursal{" +
               "codigo_sucursal='" + codigo_sucursal + '\'' +
               ", direccion='" + direccion + '\'' +
               ", telefono='" + telefono + '\'' +
               '}';
    }
}