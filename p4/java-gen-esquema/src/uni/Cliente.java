package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.CascadeType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;

import java.util.HashSet;
import java.util.Set;


@Entity
@Table(name = "Cliente")
public class Cliente {

    @Id
    @Column(name = "DNI")
    private String DNI;


    @ManyToMany
    @JoinTable(
      name = "clientes_cuentas",                            // nombre físico de la tabla
      joinColumns = @JoinColumn(name = "cliente_dni"),      // FK a Cliente(DNI)
      inverseJoinColumns = @JoinColumn(name = "cuenta_id")  // FK a Cuenta(IBAN)
    )
    private Set<Cuenta> Cuentas = new HashSet<>();

    @Column(name = "Nombre", nullable = false)
    private String Nombre;

    @Column(name = "Apellidos", nullable = false)
    private String Apellidos;

    @Column(name = "Edad", nullable = false)
    private int Edad;

    @ManyToOne(cascade = CascadeType.PERSIST)
    @JoinColumn(name = "Direccion_ID_Direccion")
    private Direccion Direccion;

    @Column(name = "Email", nullable = true)
    private String Email;

    @Column(name = "Telefono", nullable = false)
    private String Telefono;

    // Constructor vacío requerido por JPA
    public Cliente() {}

    // Constructor completo
    public Cliente(String dni, String nombre, String apellidos, int edad, 
                   Direccion direccion, String email, String telefono) {
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

    public Direccion getDireccion() {
        return Direccion;
    }

    public void setDireccion(Direccion direccion) {
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

	public Set<Cuenta> getCuentas() {
        return Cuentas;
    }

    public void setCuentas(Set<Cuenta> cuentas) {
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
               "DNI=" + DNI +
               ", Nombre='" + Nombre + '\'' +
               ", Apellidos='" + Apellidos + '\'' +
               ", Edad=" + Edad +
               ", Direccion=" + (Direccion != null ? Direccion.toString() : "null") +
               ", Email='" + Email + '\'' +
               ", Telefono='" + Telefono + '\'' +
               '}';
    }
    
    
}
