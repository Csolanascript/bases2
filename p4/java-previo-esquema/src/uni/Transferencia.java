package uni;

public class Transferencia extends OperacionBancaria {
    
    // Constructors
    public Transferencia() {
        super();
    }

    @ManyToOne(optional = false)
    private Cuenta iban;
    
    
    // Getters and setters
    public void setCuentaDestino(Cuenta cuentaDestino) {
        this.cuentaDestino = cuentaDestino;
    }
    
    public Cuenta getCuentaDestino() {
        return cuentaDestino;
    }
    
    @Override
    public String toString() {
        return "Transferencia [cuentaDestino=" + cuentaDestino + ", getCodigoOperacion()=" + getCodigoOperacion()
                + ", getFechaHora()=" + getFechaHora() + ", getCantidad()=" + getCantidad() + ", getDescripcion()="
                + getDescripcion() + "]";
    }
    
    private Cuenta cuentaDestino;
}
