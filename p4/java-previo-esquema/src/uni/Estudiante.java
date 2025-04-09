package uni;

import javax.persistence.Column;
import javax.persistence.Entity;


@Entity(name = "ESTUDIANTE")
public class Estudiante extends Persona {
	
	@Column(name = "CURSO")
	private int curso;
	
	public int getCurso() {
		return curso;
	}

	public void setCurso(int curso) {
		this.curso = curso;
	}
	
	@Override
	public String toString() {
		String res = super.toString();
		res += "Curso: " + curso + System.getProperty("line.separator");
		return res;
	}
	
}
