package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.ManyToMany;
import javax.persistence.CascadeType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;


@Entity
@Table(name = "Clientes")
public class Cliente {

    @Id
    @Column(name = "DNI")
    private String DNI;

	@ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(name = "clientes_cuentas",
            joinColumns = @JoinColumn(name = "cliente_dni"),
            inverseJoinColumns = @JoinColumn(name = "cuenta_id"))
    private List<Cuenta> Cuentas = new ArrayList<>();

    @Column(name = "Nombre", nullable = false)
    private String Nombre;

    @Column(name = "Apellidos", nullable = false)
    private String Apellidos;

    @Column(name = "Edad", nullable = false)
    private int Edad;

    @Column(name = "Direccion", nullable = false)
    private String Direccion;

    @Column(name = "Email", nullable = true)
    private String Email;

    @Column(name = "Telefono", nullable = false)
    private String Telefono;

    // Constructor vacío requerido por JPA
    public Cliente() {}

    // Constructor completo
    public Cliente(String dni, String nombre, String apellidos, int edad, 
                   String direccion, String email, String telefono) {
        this.DNI = dni;
        this.Nombre = nombre;
        this.Apellidos = apellidos;
        this.Edad = edad;
        this.Direccion = direccion;
        this.Email = email;
        this.Telefono = telefono;
    }

    // Getters y Setters
    public String getDni() {
        return DNI;
    }

    public void setDni(String dni) {
        this.DNI = dni;
    }

    public String getNombre() {
        return Nombre;
    }

    public void setNombre(String nombre) {
        this.Nombre = nombre;
    }

    public String getApellidos() {
        return Apellidos;
    }

    public void setApellidos(String apellidos) {
        this.Apellidos = apellidos;
    }

    public int getEdad() {
        return Edad;
    }

    public void setEdad(int edad) {
        this.Edad = edad;
    }

    public String getDireccion() {
        return Direccion;
    }

    public void setDireccion(String direccion) {
        this.Direccion = direccion;
    }

    public String getEmail() {
        return Email;
    }

    public void setEmail(String email) {
        this.Email = email;
    }

    public String getTelefono() {
        return Telefono;
    }

    public void setTelefono(String telefono) {
        this.Telefono = telefono;
    }

	public List<Cuenta> getCuentas() {
        return Cuentas;
    }

    public void setCuentas(List<Cuenta> cuentas) {
        this.Cuentas = cuentas;
    }

    public void addCuenta(Cuenta cuenta) {
        Cuentas.add(cuenta);
        cuenta.getClientes().add(this);
    }

    public void removeCuenta(Cuenta cuenta) {
        Cuentas.remove(cuenta);
        cuenta.getClientes().remove(this);
    }

    // Método toString para facilitar debugging
    @Override
    public String toString() {
        return "Cliente{" +
               "dni=" + DNI +
               ", nombre='" + Nombre + '\'' +
               ", apellidos='" + Apellidos + '\'' +
               ", edad=" + Edad +
               ", direccion='" + Direccion + '\'' +
               ", email='" + Email + '\'' +
               ", telefono='" + Telefono + '\'' +
               '}';
    }
}
