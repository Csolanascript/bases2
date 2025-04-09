package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.InheritanceType;


@Entity(name = "PROFESOR")
public class Profesor extends Persona {
	@Column(name="PUESTO")
	private String puesto;
	

	public String getPuesto() {
		return puesto;
	}

	public void setPuesto(String puesto) {
		this.puesto = puesto;
	}
	
	@Override
	public String toString() {
		String res = super.toString();
		res += "Puesto: " + puesto + System.getProperty("line.separator");
		return res;
	}
	
	

}
