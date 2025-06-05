## Come usare lo script `Fatture in Cloud API Tester.sh`

Di seguito trovi una piccola *“guida per l’utente”* che spiega come preparare, configurare ed eseguire lo script interattivo che hai incollato.

---

### 1 ▪ Prerequisiti

| Componente             | Verifica rapida  | Note                                                                     |
| ---------------------- | ---------------- | ------------------------------------------------------------------------ |
| **Bash ≥ 4**           | `bash --version` | Presente di default su Linux/macOS. Su Windows usa WSL o Git Bash.       |
| **curl**               | `curl --version` | Necessario per fare le chiamate HTTP.                                    |
| **jq** *(facoltativo)* | `jq --version`   | Serve solo per formattare l’output JSON; lo script funziona anche senza. |

> **Installazione rapida (Debian/Ubuntu):**
>
> ```bash
> sudo apt update && sudo apt install -y curl jq
> ```

---

### 2 ▪ Scarica & rendi eseguibile lo script

```bash
# copia-incolla il contenuto in un file
nano fic_api_tester.sh      # oppure vim, code, ecc.

# rendilo eseguibile
chmod +x fic_api_tester.sh
```

*(Mettilo in una cartella del tuo utente: es. `~/scripts/`)*

---

### 3 ▪ Configura le variabili principali

All’inizio del file, nella sezione **CONFIGURAZIONE**, sostituisci:

```bash
FIC_TOKEN="a/eyJ0eXA..."      # il tuo access token
FIC_COMPANY_ID="1473688"       # ID azienda
```

* **FIC\_TOKEN**: è la stringa che hai copiato da **Impostazioni ▸ Applicazioni collegate ▸ Gestisci ▸ Access token**.
* **FIC\_COMPANY\_ID**: si ricava da `Settings ▸ Dati di fatturazione` o con la chiamata `GET /user/companies`.

*(Le altre costanti `CLIENT_ID`, `INVOICE_ID`, `PAYMENT_METHOD_ID` sono solo valori d’esempio: le puoi lasciare o cambiare a piacere.)*

> 💡 **Suggerimento sicurezza**
> Invece di scrivere il token in chiaro nel file, puoi esportarlo come variabile d’ambiente prima di lanciare lo script, così:
>
> ```bash
> export FIC_TOKEN="a/eyJ0eXA..."   # valido solo per la sessione corrente
> ./fic_api_tester.sh
> ```

---

### 4 ▪ Esecuzione

```bash
./fic_api_tester.sh
```

Lo script:

1. Mostra un header colorato con la configurazione attuale.
2. Presenta un **menu numerato**; digita il numero dell’operazione e premi ↵ Invio.
3. Per ogni richiesta:

   * Vedi il riepilogo di **endpoint**, **metodo**, **descrizione**, token abbreviato e company ID.
   * Il comando `curl` generato viene mostrato per intero (utile per copiarlo altrove).
   * Viene eseguita la chiamata e ritorna **codice HTTP** + corpo formattato (se c’è `jq`).
4. Premi **Invio** per tornare al menu o **0** per uscire.

---

### 5 ▪ Cosa fanno le voci di menu

| #      | Descrizione                                                                           | Endpoint chiamato                                   |
| ------ | ------------------------------------------------------------------------------------- | --------------------------------------------------- |
| **1**  | Verifica token / ping API                                                             | `GET /user/info`                                    |
| **2**  | Elenco aziende                                                                        | `GET /user/companies`                               |
| **3**  | Metodi di pagamento                                                                   | `GET /c/{company_id}/info/payment_methods`          |
| **4**  | Conti di pagamento                                                                    | `GET /c/{company_id}/info/payment_accounts`         |
| **5**  | Aliquote IVA                                                                          | `GET /c/{company_id}/info/vat_types`                |
| **6**  | Lista clienti (primi 5)                                                               | `GET /c/{company_id}/entities/clients`              |
| **7**  | Dettaglio cliente                                                                     | `GET /c/{company_id}/entities/clients/{id}`         |
| **8**  | Liste fatture (ultime 5)                                                              | `GET /c/{company_id}/issued_documents?type=invoice` |
| **9**  | Crea cliente “di test”                                                                | `POST /entities/clients`                            |
| **10** | Crea fattura “di test”                                                                | `POST /issued_documents`                            |
| **11** | **Audit permessi**: iterazione rapida su 9 endpoint per verificare gli scope concessi |                                                     |

Le funzioni **9** e **10** costruiscono al volo un payload JSON con `date +%s` per evitare conflitti di nomi/duplicati.

---

### 6 ▪ Modificare/estendere lo script

* **Aggiungere un nuovo endpoint**

  1. Crea una nuova funzione nello stile `my_new_call() { … }`.
  2. Inserisci una riga nel `case` del `MAIN LOOP`, ad es. `12) my_new_call ;;`.
  3. Aggiorna il testo del menu in `show_menu()`.

* **Cambiare colori**: sono definiti in un’unica sezione; basta modificare le sequenze ANSI.

* **Integrare con un *secrets manager***: togli la variabile hard-coded e recupera il token da `pass`, `aws secretsmanager`, `gopass`, ecc.

---

### 7 ▪ Domande frequenti

| Domanda                                    | Risposta sintetica                                                                                                |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| **Il token scade?**                        | No, finché non lo rigeneri/disconnetti dall’interfaccia.                                                          |
| **Posso usare lo script per più aziende?** | Duplica lo script o passa `FIC_COMPANY_ID` come variabile d’ambiente prima di eseguirlo.                          |
| **Ricevo HTTP 403 “Forbidden”**            | Il token non ha i permessi per quell’endpoint: ri-assegna i moduli in *Applicazioni collegate*.                   |
| **È sicuro in produzione?**                | Va bene come utilità da terminale o CI interna; in produzione usa OAuth con rotazione token e logica server-side. |

---

Con questi passaggi — configurazione, esecuzione e personalizzazione — sei pronto a girare e testare qualunque endpoint dell’API v2 di **Fatture in Cloud** direttamente da shell, in modo interattivo e leggibile. Buon hacking!
