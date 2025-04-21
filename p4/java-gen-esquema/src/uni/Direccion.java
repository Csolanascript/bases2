package uni;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.GenerationType;

@Entity
@Table(name = "Direccion")
public class Direccion {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "direccion_seq")
    @SequenceGenerator(name = "direccion_seq", sequenceName = "DIRECCION_SEQ", allocationSize = 1)
    @Column(name = "ID_Direccion")
    private Long ID_Direccion;

    @Column(name = "Calle", nullable = false)
    private String Calle;

    @Column(name = "CodigoPostal", nullable = false)
    private String CodigoPostal;

    @Column(name = "Ciudad", nullable = false)
    private String Ciudad;

    // Constructor vacío requerido por JPA
    public Direccion() {
    }

    // Constructor completo
    public Direccion(String Calle, String CodigoPostal, String Ciudad) {
        this.Calle = Calle;
        this.CodigoPostal = CodigoPostal;
        this.Ciudad = Ciudad;
    }

    // Getters y Setters

    public Long getID_Direccion() {
        return ID_Direccion;
    }

    public void setID_Direccion(Long ID_Direccion) {
        this.ID_Direccion = ID_Direccion;
    }

    public String getCalle() {
        return Calle;
    }

    public void setCalle(String Calle) {
        this.Calle = Calle;
    }

    public String getCodigoPostal() {
        return CodigoPostal;
    }

    public void setCodigoPostal(String CodigoPostal) {
        this.CodigoPostal = CodigoPostal;
    }

    public String getCiudad() {
        return Ciudad;
    }

    public void setCiudad(String Ciudad) {
        this.Ciudad = Ciudad;
    }

    // Método toString para facilitar debugging
    @Override
    public String toString() {
        return "Direccion{" +
                "ID_Direccion=" + ID_Direccion +
                ", Calle='" + Calle + '\'' +
                ", CodigoPostal='" + CodigoPostal + '\'' +
                ", Ciudad='" + Ciudad + '\'' +
                '}';
    }
}
