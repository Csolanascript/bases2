package uni;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.PersistenceException;

public class Test3 {
	EntityManagerFactory entityManagerFactory = 
			Persistence.createEntityManagerFactory("UnidadPersistenciaAlumnos");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public void prueba() {

		
		Direccion d1 = new Direccion();
		d1.setCiudad("Teruel");
		d1.setCodPostal(50001);
		d1.setDireccion("calle a");
		Direccion d2 = new Direccion();
		d2.setCiudad("Huesca");
		d2.setCodPostal(50002);
		d2.setDireccion("calle b");
		Direccion d3 = new Direccion();
		d3.setCiudad("Zaragoza");
		d3.setCodPostal(50003);
		d3.setDireccion("calle c");
		Direccion d4 = new Direccion();
		d4.setCiudad("Zaragoza");
		d4.setCodPostal(50005);
		d4.setDireccion("calle a");

		EntityTransaction trans = em.getTransaction();
		trans.begin();
		try {
			em.persist(d1);
			em.persist(d2);
			em.persist(d3);
			em.persist(d4);
			trans.commit();
		} catch (PersistenceException e) {
			if (trans.isActive()) {
				trans.rollback();
			}
		}
		
		Telefono t1 = new Telefono();
		t1.setTelefono(444);
		Telefono t2 = new Telefono();
		t2.setTelefono(555);
		Telefono t3 = new Telefono();
		t3.setTelefono(666);
		Telefono t4 = new Telefono();
		t4.setTelefono(777);
		
		trans.begin();
		try {
			em.persist(t1);
			em.persist(t2);
			em.persist(t3);
			em.persist(t4);
			trans.commit();
		} catch (PersistenceException e) {
			if (trans.isActive()) {
				trans.rollback();
			}
		}
		
		Asignatura a1 = new Asignatura();
		a1.setNombre("BD2");
		Asignatura a2 = new Asignatura();
		a2.setNombre("EDA");
		Asignatura a3 = new Asignatura();
		a3.setNombre("TC");
		trans.begin();
		try {
			em.persist(a1);
			em.persist(a2);
			em.persist(a3);
			trans.commit();
		} catch (PersistenceException e) {
			if (trans.isActive()) {
				trans.rollback();
			}
		}
		
		Estudiante e1 = new Estudiante();
		e1.setNombre("Pepe");
		e1.setEdad(20);
		e1.setCurso(1);
		e1.setDireccionContacto(d1);
		e1.addTelefono(t1);
		t1.setPersona(e1);
		e1.addTelefono(t2);
		t2.setPersona(e1);
		e1.addAsignatura(a1); 
		e1.addAsignatura(a2); 
		
		Estudiante e2 = new Estudiante();
		e2.setNombre("Ana");
		e2.setEdad(21);
		e2.setCurso(2);
		e2.setDireccionContacto(d2);
		e2.addTelefono(t3);
		t3.setPersona(e2);
		e2.addAsignatura(a3);
		
		EntityTransaction trans1 = em.getTransaction();
		trans1.begin();
		try{
			em.persist(e1);
			em.persist(e2);
			trans1.commit();
		} catch (PersistenceException e) {
			if (trans.isActive()) {
				trans1.rollback();
			}
			System.out.println("ERROR persistiendo estudiantes");
		}
		
		Profesor p1 = new Profesor();
		p1.setDireccionContacto(d3);
		p1.setEdad(40);
		p1.setNombre("Pepe");
		p1.setPuesto("Prof1");
		p1.addAsignatura(a3);
		p1.addAsignatura(a2);
		p1.addTelefono(t4);
		t4.setPersona(p1);
		
		Profesor p2 = new Profesor();
		p2.setDireccionContacto(d4);
		p2.setEdad(39);
		p2.setNombre("Juana");
		p2.setPuesto("Prof2");
		p2.addAsignatura(a1);
		p2.addAsignatura(a2);
		
		trans.begin();
		try{
			em.persist(p1);
			em.persist(p2);
			trans.commit();
		} catch (PersistenceException e) {
			if (trans.isActive()) {
				trans.rollback();
			}
			System.out.println("ERROR persistiendo profesores");
		}
		
//		trans.begin();
//		try{
//			em.remove(e1);
//			trans.commit();
//		} catch (PersistenceException e) {
//			if (trans.isActive()) {
//				trans.rollback();
//			}
//			System.out.println("Excepcion borrado");
//		}

	}
	
	public static void main(String[] args) {
		Test3 t = new Test3();
		t.prueba();
	}
	

}
