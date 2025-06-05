# fatture-in-cloud
Con questa procedura puoi avere accesso alle api di fatture in cloud 
### Procedura passo-passo per ottenere l’**Access Token** di Fatture in Cloud (v2)

*(valido quando devi lavorare solo sul tuo account/azienda e vuoi evitare di implementare subito OAuth)*

| Fase                                | Azione in Web-App                                                              | Dettagli                                                                                                                                                                          |
| ----------------------------------- | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Attiva l’area “Sviluppatore”** | `Impostazioni ▸ … ▸ Sviluppatore` → **+ Crea applicazione**                    | Dai un nome, lascia “Privata” e salva.                                                                                                                                            |
| **2. Prendi “Client ID”**           | Apri la scheda dell’app appena creata                                          | Trovi **App ID** (interno) e **Client ID** (pubblico). Copia il Client ID: ti servirà fra poco.                                                                                   |
| **3. Collega l’app al tuo account** | `Impostazioni ▸ Applicazioni collegate` → **+ Collega una nuova applicazione** | 1) Incolla il Client ID<br>2) Seleziona l’azienda (puoi aggiungerne più d’una)<br>3) Spunta i moduli/per­messi che ti servono (es. `settings:r,w`, `entity.clients:r,w`, ecc.)    |
| **4. Recupera il token**            | Dopo il collegamento si apre **Gestisci applicazione**                         | Nella sezione **Access token** compare la stringa che inizia con `a/…` - copiala e conservala in un posto sicuro. Puoi rigenerarla in futuro. ([developers.fattureincloud.it][1]) |

> **Perché funziona:** si tratta del flusso *Manual Authentication* suggerito dagli sviluppatori per script o test rapidi; il token non scade mai (finché non lo rigeneri o revochi) e vale per le sole aziende/per­messi concessi. ([developers.fattureincloud.it][1])

---

### Esempio di shell-script per testare le API

```bash
#!/usr/bin/env bash
API="https://api-v2.fattureincloud.it"
TOKEN="TUO_TOKEN"      # oppure esporta export FIC_TOKEN=...
COMPANY_ID=123456      # vedi Settings ▸ Dati di fatturazione o GET /user/companies

# Ping di prova: info generali
curl -s "$API/info" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq .
```

---

## Creare un **metodo di pagamento** (Metodi di pagamento)

### 1. Da interfaccia

`Impostazioni ▸ Metodi di pagamento` → **Nuovo metodo**
Compila *Nome* (es. “Bonifico Bancario”), *Tipo* (bonifico, contanti, carta, …), eventuali rate e salva.

### 2. Via API

Endpoint: `POST /c/{company_id}/settings/payment_methods` ([github.com][2])

```bash
curl -X POST "$API/c/$COMPANY_ID/settings/payment_methods" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "data": {
          "name": "Bonifico Bancario",
          "type": "transfer",
          "is_default": false,
          "details": [
            { "title": "IBAN", "value": "IT60X0542811101000000123456" }
          ]
        }
      }'
```

Per verificare ciò che hai creato:

```bash
curl -s "$API/c/$COMPANY_ID/info/payment_methods" \
  -H "Authorization: Bearer $TOKEN" | jq .
```

([github.com][3])

---

### Suggerimenti rapidi

* **Sicurezza:** conserva il token in variabile d’ambiente o in un secrets-manager; evita di committarlo.
* **Scope minimi:** concedi solo i permessi necessari; se in futuro ne serviranno altri potrai modificarli dalla stessa schermata “Applicazioni collegate”.
* **Rotazione token:** se automatizzi processi di produzione, pianifica la rigenerazione periodica (il nuovo token invalida il precedente).
* **Multi-account:** se un giorno dovrai far autorizzare altre aziende, passa a OAuth 2.0 Authorization Code o Device Code Flow — il flusso manuale non scala. ([developers.fattureincloud.it][1])

Con questi passaggi hai il token, lo script di verifica e l’endpoint per inserire (o modificare) i tuoi metodi di pagamento direttamente da linea di comando o codice. Buon lavoro!

[1]: https://developers.fattureincloud.it/docs/authentication/manual-authentication "Manual Authentication | Fatture in Cloud \ Devs: API V2 & SDKs"
[2]: https://github.com/fattureincloud/fattureincloud-csharp-sdk?utm_source=chatgpt.com "fattureincloud/fattureincloud-csharp-sdk: Fatture in Cloud ... - GitHub"
[3]: https://github.com/fattureincloud/fattureincloud-python-sdk?utm_source=chatgpt.com "FattureInCloud Python SDK - GitHub"
