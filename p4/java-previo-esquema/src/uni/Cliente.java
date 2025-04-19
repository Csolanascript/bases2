package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.ManyToMany;
import javax.persistence.CascadeType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;


import java.util.List;
import java.util.ArrayList;


@Entity
@Table(name = "Cliente")
public class Cliente {

    @Id
    @Column(name = "dni")
    private Integer dni;

	@ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(name = "clientes_cuentas",
            joinColumns = @JoinColumn(name = "cliente_dni"),
            inverseJoinColumns = @JoinColumn(name = "cuenta_id"))
    private List<Cuenta> cuentas = new ArrayList<>();

    @Column(name = "nombre", nullable = false)
    private String nombre;

    @Column(name = "apellidos", nullable = false)
    private String apellidos;

    @Column(name = "edad", nullable = false)
    private int edad;

    @Column(name = "direccion", nullable = false)
    private String direccion;

    @Column(name = "email", nullable = true)
    private String email;

    @Column(name = "telefono", nullable = false)
    private String telefono;

    // Constructor vacío requerido por JPA
    public Cliente() {}

    // Constructor completo
    public Cliente(Integer dni, String nombre, String apellidos, int edad, 
                   String direccion, String email, String telefono) {
        this.dni = dni;
        this.nombre = nombre;
        this.apellidos = apellidos;
        this.edad = edad;
        this.direccion = direccion;
        this.email = email;
        this.telefono = telefono;
    }

    // Getters y Setters
    public Integer getDni() {
        return dni;
    }

    public void setDni(Integer dni) {
        this.dni = dni;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public int getEdad() {
        return edad;
    }

    public void setEdad(int edad) {
        this.edad = edad;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

	public List<Cuenta> getCuentas() {
        return cuentas;
    }

    public void setCuentas(List<Cuenta> cuentas) {
        this.cuentas = cuentas;
    }

    public void addCuenta(Cuenta cuenta) {
        cuentas.add(cuenta);
        cuenta.getClientes().add(this);
    }

    public void removeCuenta(Cuenta cuenta) {
        cuentas.remove(cuenta);
        cuenta.getClientes().remove(this);
    }

    // Método toString para facilitar debugging
    @Override
    public String toString() {
        return "Cliente{" +
               "dni=" + dni +
               ", nombre='" + nombre + '\'' +
               ", apellidos='" + apellidos + '\'' +
               ", edad=" + edad +
               ", direccion='" + direccion + '\'' +
               ", email='" + email + '\'' +
               ", telefono='" + telefono + '\'' +
               '}';
    }
}
