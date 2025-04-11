package uni;

public class Transferencia extends OperacionBancaria {
    
    // Constructors
    public Transferencia() {
        super();
    }

    @ManyToOne(optional = false)
    private Cuenta iban_receptor;
    
    
    // Getters and setters
    public void setCuentaDestino(Cuenta cuentaDestino) {
        this.iban_receptor = iban_receptor;
    }
    
    public Cuenta getCuentaDestino() {
        return iban_receptor;
    }
    
    @Override
    public String toString() {
        return super.toString() + " Transferencia [CuentaDestino=" + iban_receptor + "]";
    }
}
