package uni;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.PersistenceException;

public class testFind {
	EntityManagerFactory entityManagerFactory = 
			Persistence.createEntityManagerFactory("UnidadPersistenciaAlumnos");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public void prueba() {
		
		Persona p = em.find(Persona.class, 1L);
		
		System.out.println(em.contains(p));

		//System.out.println(p);
		
	}
	
	public static void main(String[] args) {
		testFind test = new testFind();
		test.prueba();
	}

}
