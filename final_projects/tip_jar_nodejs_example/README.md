# Tip Jar NodeJS Example

Un exemplu complet de utilizare a contractului Tip Jar din NodeJS folosind un private key. Acest script permite trimiterea de tips și interogarea statisticilor direct din linia de comandă.

## 📋 Cerințe

- Node.js 18+
- Contractul Tip Jar deployat (Package ID și TipJar Object ID)
- SUI testnet tokens pentru gas și tips

## 🚀 Setup Rapid

### 1. Instalare Dependințe
```bash
npm install
```

### 2. Configurare Environment
```bash
cp .env.example .env
```

### 3. Configurare .env
Editează fișierul `.env` cu valorile tale:
```env
SUI_NETWORK=testnet
PRIVATE_KEY=your_64_character_private_key_here
PACKAGE_ID=your_deployed_package_id_here
TIP_JAR_OBJECT_ID=your_tip_jar_object_id_here
```

### 4. Test Configurație
```bash
npm start
```

## 🎯 Comenzi Disponibile

### Verificare Setup
```bash
npm start
```
Verifică configurația și afișează informații despre wallet și contract.

### Trimitere Tip
```bash
npm run send-tip <amount_in_sui>
```

Exemple:
```bash
npm run send-tip 0.1      # Trimite 0.1 SUI
npm run send-tip 0.05     # Trimite 0.05 SUI
npm run send-tip 1.5      # Trimite 1.5 SUI
```

### Statistici și Evenimente
```bash
npm run get-stats
```
Afișează statisticile curente ale tip jar-ului și ultimele 5 evenimente.

## 📁 Structura Proiectului

```
tip_jar_nodejs_example/
├── package.json           # Dependințe și scripturi
├── .env.example          # Template pentru configurare
├── config.js             # Configurație Sui client și keypair
├── index.js              # Script principal pentru verificare setup
├── send-tip.js           # Script pentru trimiterea de tips
├── get-stats.js          # Script pentru citirea statisticilor
└── README.md            # Această documentație
```

## 🔧 Configurația Detaliată

### Environment Variables

#### Obligatorii:
- `PRIVATE_KEY`: Cheia privată (64 caractere hex, fără prefix 0x)
- `PACKAGE_ID`: ID-ul package-ului contractului deployat
- `TIP_JAR_OBJECT_ID`: ID-ul obiectului TipJar shared

#### Opționale:
- `SUI_NETWORK`: Rețeaua Sui (default: testnet)
- `SUI_RPC_URL`: Endpoint-ul RPC custom (default: folosește URL-ul standard pentru rețea)

### Obținerea Private Key

Pentru a obține private key din Sui CLI:
```bash
# Afișează toate adresele
sui client addresses

# Exportă private key pentru o adresă
sui keytool export --key-identity <address> --key-format hex
```

## 📊 Exemple de Utilizare

### Exemplu Complet de Workflow

1. **Verificare setup:**
```bash
npm start
```

2. **Trimitere primul tip:**
```bash
npm run send-tip 0.1
```

3. **Verificare statistici:**
```bash
npm run get-stats
```

### Output Exemplu

```bash
$ npm run send-tip 0.1

💰 Sending tip of 0.1 SUI...
   Amount in MIST: 100000000
📡 Executing transaction...
✅ Transaction successful!
   Digest: ABC123XYZ...
   Gas used: 1234567
📢 Events emitted:
   Event 1: {
     "tip_amount": "100000000",
     "tipper": "0x123...",
     "tip_jar_id": "0x456...",
     "new_total": "500000000",
     "new_count": "5"
   }
🎉 Tip sent successfully!
```

```bash
$ npm run get-stats

📊 Fetching tip jar statistics...
📈 Tip Jar Statistics:
   Owner: 0x789...
   Total tips received: 500000000 MIST (0.5 SUI)
   Number of tips: 5
   Average tip: 100000000 MIST (0.1 SUI)

📜 Fetching last 5 tip events...
📋 Recent Tips:
   1. Amount: 100000000 MIST (0.1 SUI)
      Tipper: 0x123...
      Timestamp: 2024-01-15T10:30:00.000Z
      Transaction: ABC123XYZ...
```

## 🔐 Securitate

### Bune Practici:
- ✅ Nu commita niciodată fișierul `.env` în repository
- ✅ Folosește un wallet separat pentru testare
- ✅ Verifică întotdeauna network-ul înainte de tranzacții
- ✅ Validează sumele înainte de trimitere

### Avertismente:
- ⚠️ Private key-ul oferă acces complet la wallet
- ⚠️ Folosește doar pe testnet pentru dezvoltare
- ⚠️ Pentru producție, consideră folosirea unui wallet hardware

## 🛠️ Debugging

### Probleme Comune:

1. **"Missing required environment variable"**
   - Verifică că toate variabilele din `.env` sunt setate

2. **"Tip jar object not found"**
   - Verifică că `TIP_JAR_OBJECT_ID` este corect
   - Asigură-te că contractul este deployat pe rețeaua corectă

3. **"Insufficient balance"**
   - Verifică balansul wallet-ului: `sui client balance`
   - Obține SUI de pe faucet: https://faucet.sui.io/

4. **"Invalid private key"**
   - Private key-ul trebuie să fie 64 caractere hex
   - Nu include prefix-ul "0x"

### Verificare Configurație:
```bash
# Verifică adresa wallet-ului
node -e "import('./config.js').then(({senderAddress}) => console.log('Address:', senderAddress))"

# Verifică balansul
sui client balance --address <your_address>
```

## 📚 Resurse Utile

- [Sui TypeScript SDK Documentation](https://sdk.mystenlabs.com/typescript)
- [Sui CLI Documentation](https://docs.sui.io/references/cli)
- [Sui Faucet](https://faucet.sui.io/) pentru testnet tokens
- [Sui Explorer](https://suiscan.xyz/testnet/home) pentru verificarea tranzacțiilor

## 🎓 Concepte Demonstrate

Acest exemplu demonstrează:
- ✅ Configurarea unui client Sui în NodeJS
- ✅ Managementul keypair-urilor din private key
- ✅ Construirea și semnarea tranzacțiilor
- ✅ Apelarea funcțiilor din contracte Move
- ✅ Procesarea evenimentelor și rezultatelor
- ✅ Interogarea datelor din obiectele shared
- ✅ Gestionarea erorilor și validarea input-ului

---

Parte din Sui Development Workshop • Perfect pentru învățarea integrării NodeJS cu Sui