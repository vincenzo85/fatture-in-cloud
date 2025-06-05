#!/bin/bash

# ==============================================================================
# Fatture in Cloud API Tester
# ==============================================================================
# Descrizione: Script interattivo per testare le API di Fatture in Cloud
# Autore: Assistant
# Data: 2025-06-05
# ==============================================================================

# ------------------------------------------------------------------------------
# CONFIGURAZIONE - Modifica questi valori con i tuoi dati
# ------------------------------------------------------------------------------
FIC_TOKEN="....."
FIC_COMPANY_ID="......."  

# Valori di esempio - modificali secondo necessità
CLIENT_ID="12345"              # ID di un cliente esistente
INVOICE_ID="67890"              # ID di una fattura esistente
PAYMENT_METHOD_ID="444656"      # ID di un metodo di pagamento

# ------------------------------------------------------------------------------
# COLORI PER OUTPUT
# ------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ------------------------------------------------------------------------------
# FUNZIONI UTILITY
# ------------------------------------------------------------------------------

# Stampa header
print_header() {
    echo -e "\n${BLUE}${BOLD}=================================================================================${NC}"
    echo -e "${CYAN}${BOLD}                     Fatture in Cloud API Tester${NC}"
    echo -e "${BLUE}${BOLD}=================================================================================${NC}\n"
}

# Stampa info richiesta
print_request_info() {
    echo -e "${YELLOW}${BOLD}📋 DETTAGLI RICHIESTA:${NC}"
    echo -e "${CYAN}Endpoint:${NC} $1"
    echo -e "${CYAN}Metodo:${NC} $2"
    if [ ! -z "$3" ]; then
        echo -e "${CYAN}Descrizione:${NC} $3"
    fi
    echo -e "${CYAN}Token:${NC} ${FIC_TOKEN:0:10}..."
    echo -e "${CYAN}Company ID:${NC} $FIC_COMPANY_ID"
    echo ""
}

# Esegui curl con formatting
execute_curl() {
    local url=$1
    local method=$2
    local data=$3
    
    echo -e "${GREEN}${BOLD}🚀 ESECUZIONE RICHIESTA...${NC}\n"
    
    # Costruisci comando curl
    if [ "$method" = "GET" ]; then
        cmd="curl -s -X GET \"$url\" \
            -H \"Authorization: Bearer $FIC_TOKEN\" \
            -H \"Content-Type: application/json\" \
            -H \"Accept: application/json\""
    else
        cmd="curl -s -X $method \"$url\" \
            -H \"Authorization: Bearer $FIC_TOKEN\" \
            -H \"Content-Type: application/json\" \
            -H \"Accept: application/json\" \
            -d '$data'"
    fi
    
    # Mostra comando
    echo -e "${CYAN}Comando:${NC}"
    echo "$cmd"
    echo ""
    
    # Esegui e formatta risposta
    echo -e "${GREEN}${BOLD}📥 RISPOSTA:${NC}"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -X GET "$url" \
            -H "Authorization: Bearer $FIC_TOKEN" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$url" \
            -H "Authorization: Bearer $FIC_TOKEN" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "$data")
    fi
    
    # Estrai status code e body
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | sed '$d')
    
    # Mostra status code con colore appropriato
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "${GREEN}Status Code: $http_code ✅${NC}"
    else
        echo -e "${RED}Status Code: $http_code ❌${NC}"
    fi
    echo ""
    
    # Formatta JSON se disponibile jq
    if command -v jq &> /dev/null; then
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo "$body"
    fi
}

# Pausa
pause() {
    echo -e "\n${YELLOW}Premi INVIO per continuare...${NC}"
    read
}

# ------------------------------------------------------------------------------
# MENU PRINCIPALE
# ------------------------------------------------------------------------------

show_menu() {
    clear
    print_header
    
    echo -e "${BOLD}CONFIGURAZIONE ATTUALE:${NC}"
    echo -e "Token: ${GREEN}${FIC_TOKEN:0:20}...${NC}"
    echo -e "Company ID: ${GREEN}$FIC_COMPANY_ID${NC}"
    echo ""
    
    echo -e "${BOLD}SCEGLI UN'OPERAZIONE:${NC}\n"
    echo -e "${CYAN}[1]${NC}  Test Connessione (User Info)"
    echo -e "${CYAN}[2]${NC}  Informazioni Azienda"
    echo -e "${CYAN}[3]${NC}  Lista Metodi di Pagamento"
    echo -e "${CYAN}[4]${NC}  Lista Conti di Pagamento"
    echo -e "${CYAN}[5]${NC}  Lista Aliquote IVA"
    echo -e "${CYAN}[6]${NC}  Lista Clienti"
    echo -e "${CYAN}[7]${NC}  Dettaglio Cliente Specifico"
    echo -e "${CYAN}[8]${NC}  Lista Fatture Emesse"
    echo -e "${CYAN}[9]${NC}  Crea Cliente di Test"
    echo -e "${CYAN}[10]${NC} Crea Fattura di Test"
    echo -e "${CYAN}[11]${NC} Test Permessi (Prova tutti gli endpoint)"
    echo ""
    echo -e "${RED}[0]${NC}  Esci"
    echo ""
}

# ------------------------------------------------------------------------------
# OPERAZIONI API
# ------------------------------------------------------------------------------

# 1. Test connessione
test_connection() {
    clear
    print_header
    print_request_info "https://api-v2.fattureincloud.it/user/info" "GET" "Test della connessione e validità del token"
    execute_curl "https://api-v2.fattureincloud.it/user/info" "GET"
    pause
}

# 2. Info azienda
company_info() {
    clear
    print_header
    print_request_info "https://api-v2.fattureincloud.it/user/companies" "GET" "Recupera informazioni sulle aziende associate"
    execute_curl "https://api-v2.fattureincloud.it/user/companies" "GET"
    pause
}

# 3. Metodi di pagamento
payment_methods() {
    clear
    print_header
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/info/payment_methods" "GET" "Lista metodi di pagamento configurati"
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/info/payment_methods" "GET"
    pause
}

# 4. Conti di pagamento
payment_accounts() {
    clear
    print_header
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/info/payment_accounts" "GET" "Lista conti di pagamento"
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/info/payment_accounts" "GET"
    pause
}

# 5. Aliquote IVA
vat_types() {
    clear
    print_header
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/info/vat_types" "GET" "Lista aliquote IVA disponibili"
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/info/vat_types" "GET"
    pause
}

# 6. Lista clienti
list_clients() {
    clear
    print_header
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/entities/clients?per_page=5" "GET" "Lista primi 5 clienti"
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/entities/clients?per_page=5" "GET"
    pause
}

# 7. Dettaglio cliente
client_detail() {
    clear
    print_header
    echo -e "${YELLOW}ID Cliente attuale: $CLIENT_ID${NC}"
    echo -n "Inserisci ID cliente (INVIO per usare quello configurato): "
    read input_id
    if [ ! -z "$input_id" ]; then
        CLIENT_ID=$input_id
    fi
    
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/entities/clients/$CLIENT_ID" "GET" "Dettaglio cliente ID: $CLIENT_ID"
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/entities/clients/$CLIENT_ID" "GET"
    pause
}

# 8. Lista fatture
list_invoices() {
    clear
    print_header
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/issued_documents?type=invoice&per_page=5" "GET" "Lista ultime 5 fatture"
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/issued_documents?type=invoice&per_page=5" "GET"
    pause
}

# 9. Crea cliente test
create_test_client() {
    clear
    print_header
    
    local data='{
  "data": {
    "type": "person",
    "name": "Test Cliente '$(date +%s)'",
    "vat_number": "",
    "tax_code": "TSTCLT80A01H501U",
    "address_street": "Via Test 123",
    "address_postal_code": "00100",
    "address_city": "Roma",
    "address_province": "RM",
    "country": "Italia",
    "country_iso": "IT",
    "email": "test'$(date +%s)'@example.com",
    "phone": "06123456"
  }
}'
    
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/entities/clients" "POST" "Crea un cliente di test"
    echo -e "${YELLOW}Dati cliente:${NC}"
    echo "$data" | jq '.' 2>/dev/null || echo "$data"
    echo ""
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/entities/clients" "POST" "$data"
    pause
}

# 10. Crea fattura test
create_test_invoice() {
    clear
    print_header
    
    echo -e "${YELLOW}ID Cliente attuale: $CLIENT_ID${NC}"
    echo -e "${YELLOW}ID Metodo Pagamento attuale: $PAYMENT_METHOD_ID${NC}"
    echo -n "Premi INVIO per continuare o CTRL+C per annullare: "
    read
    
    local data='{
  "data": {
    "type": "invoice",
    "entity": {
      "id": '$CLIENT_ID'
    },
    "date": "'$(date +%Y-%m-%d)'",
    "currency": {
      "id": "EUR"
    },
    "language": {
      "code": "it"
    },
    "items_list": [
      {
        "name": "Test Service - '$(date +%s)'",
        "net_price": 10.00,
        "category": "service",
        "qty": 1,
        "vat": {
          "id": 0
        }
      }
    ],
    "payment_method": {
      "id": '$PAYMENT_METHOD_ID'
    }
  }
}'
    
    print_request_info "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/issued_documents" "POST" "Crea una fattura di test"
    echo -e "${YELLOW}Dati fattura:${NC}"
    echo "$data" | jq '.' 2>/dev/null || echo "$data"
    echo ""
    execute_curl "https://api-v2.fattureincloud.it/c/$FIC_COMPANY_ID/issued_documents" "POST" "$data"
    pause
}

# 11. Test tutti i permessi
test_all_permissions() {
    clear
    print_header
    echo -e "${YELLOW}${BOLD}TEST COMPLETO PERMESSI API${NC}\n"
    
    endpoints=(
        "user/info|Informazioni utente"
        "user/companies|Lista aziende"
        "c/$FIC_COMPANY_ID/info/payment_methods|Metodi pagamento"
        "c/$FIC_COMPANY_ID/info/payment_accounts|Conti pagamento"
        "c/$FIC_COMPANY_ID/info/vat_types|Aliquote IVA"
        "c/$FIC_COMPANY_ID/entities/clients?per_page=1|Clienti"
        "c/$FIC_COMPANY_ID/issued_documents?type=invoice&per_page=1|Fatture"
        "c/$FIC_COMPANY_ID/products?per_page=1|Prodotti"
        "c/$FIC_COMPANY_ID/receipts?per_page=1|Ricevute"
    )
    
    echo -e "${CYAN}Testerò ${#endpoints[@]} endpoint...${NC}\n"
    
    for endpoint in "${endpoints[@]}"; do
        IFS='|' read -r path description <<< "$endpoint"
        echo -e "${BOLD}Testing: $description${NC}"
        echo -e "Endpoint: https://api-v2.fattureincloud.it/$path"
        
        http_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "https://api-v2.fattureincloud.it/$path" \
            -H "Authorization: Bearer $FIC_TOKEN" \
            -H "Content-Type: application/json")
        
        if [ "$http_code" = "200" ]; then
            echo -e "Status: ${GREEN}$http_code ✅${NC}"
        elif [ "$http_code" = "403" ]; then
            echo -e "Status: ${RED}$http_code ❌ (Permesso negato)${NC}"
        elif [ "$http_code" = "401" ]; then
            echo -e "Status: ${RED}$http_code ❌ (Token non valido)${NC}"
        else
            echo -e "Status: ${YELLOW}$http_code ⚠️${NC}"
        fi
        echo ""
    done
    
    pause
}

# ------------------------------------------------------------------------------
# MAIN LOOP
# ------------------------------------------------------------------------------

# Verifica dipendenze
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Errore: curl non è installato!${NC}"
    echo "Installa curl con: sudo apt-get install curl"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Attenzione: jq non è installato. L'output JSON non sarà formattato.${NC}"
    echo "Installa jq con: sudo apt-get install jq"
    echo ""
fi

# Verifica configurazione
if [ "$FIC_TOKEN" = "IL_TUO_TOKEN_QUI" ] || [ "$FIC_COMPANY_ID" = "IL_TUO_COMPANY_ID_QUI" ]; then
    echo -e "${RED}${BOLD}ATTENZIONE: Devi configurare il token e il company ID!${NC}"
    echo -e "Modifica le variabili all'inizio dello script:"
    echo -e "  FIC_TOKEN=\"il_tuo_token\""
    echo -e "  FIC_COMPANY_ID=\"il_tuo_company_id\""
    echo ""
    exit 1
fi

# Loop principale
while true; do
    show_menu
    echo -n "Scegli un'opzione: "
    read choice
    
    case $choice in
        1) test_connection ;;
        2) company_info ;;
        3) payment_methods ;;
        4) payment_accounts ;;
        5) vat_types ;;
        6) list_clients ;;
        7) client_detail ;;
        8) list_invoices ;;
        9) create_test_client ;;
        10) create_test_invoice ;;
        11) test_all_permissions ;;
        0) 
            echo -e "\n${GREEN}Arrivederci!${NC}\n"
            exit 0 
            ;;
        *)
            echo -e "${RED}Opzione non valida!${NC}"
            sleep 1
            ;;
    esac
done
