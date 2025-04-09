package uni;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.Query;

public class TestRemove {
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("UnidadPersistenciaAlumnos");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public void prueba() {

		EntityTransaction trans = em.getTransaction();
	
		Persona p = em.find(Persona.class, 1L);
		
		trans.begin();
		try {
			em.remove(p);
			trans.commit();
		} catch(Exception e) {
			if (trans.isActive()) {
				trans.rollback();
			}
		}
		
		
	}
	
	public static void main(String[] args) {
		TestRemove t = new TestRemove();
		t.prueba();
	}
	
	

//	
//	System.out.println(em.contains(d1));
	

}
