package uni;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.NamedQuery;
import javax.persistence.Persistence;
import javax.persistence.Query;



public class testQuery {
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("UnidadPersistenciaAlumnos");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public void prueba() {
		
//		Query q0 = em.createNativeQuery("SELECT * FROM persona", Persona.class);
//		List<Persona> rest = q0.getResultList();
//		System.out.println(rest);
		
//		Query q01 = em.createQuery("SELECT p FROM PERSONA p  WHERE p.nombre = 'Ana'");
//		List<Persona> rest01 = q01.getResultList();
//		System.out.println(rest01);

		
//		Query query2 = em.createNamedQuery("todasPersonas");
//		List<Persona> res2 = query2.getResultList();
//		System.out.println(res2);
//		
//		String q1 = "select e "
//				+ "from ESTUDIANTE e "
//				+ "where e.direccionContacto.direccion = :dir and e.nombre = :nombre";
//		Query query1 = em.createQuery(q1); 
//		query1.setParameter("dir", "Calle a");
//		query1.setParameter("nombre", "Ana");
//		List<Persona> res1 = query1.getResultList();
//		System.out.println(res1);
//		
//		String q4 = "select e.nombre, e.curso "
//				+ "from ESTUDIANTE e join e.asignaturas a "
//				+ "where a.nombre= ?1";
//		Query query4 = em.createQuery(q4);
//		List<Object[]> res4 = query4.setParameter(1, "BD2").getResultList();
//		for (Object[] o : res4) {
//			System.out.print((String)o[0] + " ");
//			System.out.println((Integer)o[1]);
//		}
//				
//		String q3 = "select distinct a "
//				+ "from ESTUDIANTE e, in (e.asignaturas) a "
//				+ "where e.curso=1";
//		Query query3 = em.createQuery(q3);
//		List<Asignatura> res3 = query3.getResultList();
//		System.out.println(res3);
		
		
		Query q = em.createQuery("select distinct p "
			+ "from ESTUDIANTE e, in (e.asignaturas) ea, PROFESOR p, in (p.asignaturas) pa "
			+ "where ea.id = pa.id and e.nombre = p.nombre");
		//q.setParameter("nom", "Pepe");
		List<Persona> resQ = q.getResultList();
		System.out.println(resQ);
//		
//		String q5 = "select p from PERSONA p, in (p.telefonos) t";
//		Query query5 = em.createQuery(q5);
//		List<Asignatura> res5 = query5.getResultList();
//		System.out.println(res5);
		
		String q15 = "select p.nombre from PERSONA p order by p.edad";
		Query query15 = em.createQuery(q15);
		List<String> res15 = query15.getResultList();
		System.out.println(res15);
	}
	
	public static void main(String[] args) {
		testQuery t = new testQuery();
		t.prueba();
	}
	
	

//	
//	System.out.println(em.contains(d1));
	

}
