echo "[-] Starting reconasha.sh"
echo "[-]" $1

amass enum -noalts -nolocaldb -df $1 -min-for-recursive 7 -passive -o subdomains-amass-passive.txt & echo "[+] Starting Amass"
subfinder -dL $1 -silent -nC -nW -o subdomains-subfinder.txt -t 100 & echo "[+] Starting Subfinder" & wait;

echo "[=] Finished Amass"
echo "[=] Finished Subfinder"

cat $1 | assetfinder --subs-only | tee subdomains-assetfinder.txt & echo "[+] Starting Assetfinder"
cat $1 | parallel -j 10 ~/go/bin/crobat -s {} 2> /dev/null | tee subdomains-crobat.txt & "[+] Starting Crobat" & wait;

echo "[=] Finished Assetfinder"
echo "[=] Finished Crobat"

cat $1 | ~/go/bin/haktrails subdomains | tee subdomains-haktrails.txt & echo "[+] Starting Haktrails"
cat $1 | parallel -j 10 shosubgo -d {} -s $SHODANAPIKEY 2> /dev/null | tee subdomains-shosubgo.txt & echo "[+] Starting Shosubgo" & wait;

echo "[=] Finished Haktrails"
echo "[=] Finished Shosubgo"

cat subdomains-* | sort -u | tee subdomains.txt; echo "[-] Collected Subdomains";
cat subdomains.txt | httpx -sc -server -title -ip -cname -silent -threads 1000 -o httpx.txt & echo "[+] Starting Httpx" &
subjack -w subdomains.txt -t 500 -o subjack.txt & echo "[+] Starting Subjack" & wait;

echo "[=] Finished Httpx"
echo "[=] Finished Subjack"



cat httpx.txt | cut -d' ' -f1 | tee live.txt;

mkdir nuclei; nuclei -silent -l live.txt -t cves -c 50 -o nuclei/cves.txt -rl 1500 -c 100 & echo "Starting Nuclei-Engine"
nuclei -l live.txt -silent -t exposures -t exposed-panels -rl 1500 -c 100 -o nuclei/exposures_exposed-panels.txt & wait;
nuclei -l live.txt -silent -t misconfiguration -rl 300 -c 50 -o nuclei/misconfiguration.txt &
nuclei -l live.txt -silent -t takeovers -t default-logins -rl 1500 -c 100 -o nuclei/takeovers_default-logins.txt & wait;

echo "[=] Finished Nuclei-Engine"

echo "[+] Starting Gau"
echo subdomains.txt | gau | tee gau-output.txt;
echo "[=] Finished Gau"
