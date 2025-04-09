package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
@Table(name = "Cliente")
public class Cliente {
	
	@Id
	@Column(name = "DNI")
	private Long DNI;
	
	@Column(name = "Nombre")
	private String Nombre;

	@Column(name = "Apellidos")
	private String Apellidos;

	@Column(name = "Edad")
	private int Edad;

	@Column(name = "Direccion")
	private String Direccion;

	@Column(name = "Email", nullable = true)
	private String Email;

	@Column(name = "Telefono")
	private String Telefono;




	public Long getId() {
		return id;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}
	
	public void setId(long id) {
		this.id = id;
	}

	

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Cliente other = (Cliente) obj;
		if (DNI == null) {
			if (other.DNI != null)
				return false;
		} else if (!DNI.equals(other.DNI))
			return false;
		return true;
	}
	
	
	public String toString() {
		return nombre;
	}

}
