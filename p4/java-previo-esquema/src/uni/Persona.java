package uni;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Transient;


@Entity(name="PERSONA")
public abstract class Persona {
	@Id
	@GeneratedValue
	@Column(name = "ID")
	private Long id;
	
	@Transient
	private int paramiscuentas;
	
	@Column(name = "NOMBRE")
	private String nombre;
	
	@Column(name = "EDAD")
	private int edad;
		
	@OneToOne(cascade = CascadeType.PERSIST)
	@JoinColumn(unique = true)
	private Direccion direccionContacto;
	
	@OneToMany(mappedBy="persona", cascade = CascadeType.ALL.ALL)
	private List<Telefono> telefonos = new ArrayList<Telefono>();
	
	
	@ManyToMany(cascade = {CascadeType.PERSIST})
	private Set<Asignatura> asignaturas = new HashSet<Asignatura>();
	
	
	public Long getId() {
		return id;
	}
	
	public void setId(long id) {
		this.id = id;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	public int getEdad() {
		return edad;
	}

	public void setEdad(int edad) {
		this.edad = edad;
	}

	public Direccion getDireccionContacto() {
		return direccionContacto;
	}

	public void setDireccionContacto(Direccion direccion) {
		this.direccionContacto = direccion;
	}
	
	public void addAsignatura(Asignatura a) {
		asignaturas.add(a);
	}
	
	
	public int totalAsignaturas() {
		return asignaturas.size();
	}
	
	public void removeAsignatura(Asignatura a) {
		asignaturas.remove(a);
	}
	
	public void addTelefono(Telefono t) {
		telefonos.add(t);
	}
	
	public Telefono getTelefonoAt(int i) {
		return telefonos.get(i);
	}
	
	public int totalTelfonos() {
		return telefonos.size();
	}
	
	public void removeTelefono(Telefono t) {
		telefonos.remove(t);
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Persona other = (Persona) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}

	public String toString() {
		String res = "";
		res += "Nombre: " + getNombre() + System.getProperty("line.separator");
		res += "Edad: " + getEdad() + System.getProperty("line.separator");
		res += "Asignaturas: " + asignaturas + System.getProperty("line.separator");
		res += "Telefonos: " + telefonos + System.getProperty("line.separator");
		return res;
	}

}
