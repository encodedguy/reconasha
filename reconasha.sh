echo "[-] Starting reconasha.sh"
echo "Author: @encodedguy"
echo "[-]" $1
echo ""
sleep 2

amass enum -noalts -nolocaldb -df $1 -min-for-recursive 7 -passive -o subdomains-amass-passive.txt > /dev/null &
echo "[+] Starting Amass" &
subfinder -dL $1 -silent -nC -nW -o subdomains-subfinder.txt -t 100 > /dev/null 2> /dev/null &
echo "[+] Starting Subfinder" &
cat $1 | assetfinder --subs-only | tee subdomains-assetfinder.txt > /dev/null &
echo "[+] Starting Assetfinder" &
cat $1 | ~/go/bin/haktrails subdomains | tee subdomains-haktrails.txt > /dev/null &
echo "[+] Starting Haktrails" &
cat $1 | parallel -j 10 shosubgo -d {} -s $SHODANAPIKEY 2> /dev/null | tee subdomains-shosubgo.txt > /dev/null &
echo "[+] Starting Shosubgo" &
wait;

echo ""
echo "[=] Finished Amass"
echo "[=] Finished Subfinder"
echo "[=] Finished Assetfinder"
echo "[=] Finished Crobat"
echo "[=] Finished Haktrails"
echo "[=] Finished Shosubgo"
echo""

cat subdomains-* | sort -u | tee subdomains.txt > /dev/null;
subdomains=`wc -l subdomains.txt`;

cat subdomains.txt | httpx -sc -server -title -ip -cname -silent -t 300 -o httpx.txt > /dev/null &
echo "[+] Starting Httpx" &
subjack -w subdomains.txt -t 100 -ssl -o subjack.txt > /dev/null &
echo "[+] Starting Subjack" &
wait;

echo ""
echo "[=] Finished Httpx" &
echo "[=] Finished Subjack"
echo ""

cat httpx.txt | cut -d' ' -f1 | tee live.txt > /dev/null;
live=`wc -l live.txt`;
subjack=`wc -l subjack.txt`;

mkdir nuclei;
nuclei -silent -l live.txt -t cves -c 50 -o nuclei/cves.txt -rl 500 > /dev/null &
echo "Starting Nuclei-Engine" &
nuclei -l live.txt -silent -t exposures -t exposed-panels -rl 500 -c 50 -o nuclei/exposures_exposed-panels.txt > /dev/null &
wait;

nuclei -l live.txt -silent -t misconfiguration -rl 500 -c 50 -o nuclei/misconfiguration.txt > /dev/null &
nuclei -l live.txt -silent -t takeovers -t default-logins -rl 500 -c 50 -o nuclei/takeovers_default-logins.txt > /dev/null &
wait;

echo "[=] Finished Nuclei-Engine"

echo "[+] Starting Gau" &
echo subdomains.txt | gau | tee gau-output.txt > /dev/null;
echo "[=] Finished Gau"


echo ""
echo "[-] Collected $subdomains Subdomains";
echo "[-] Collected $live Live Hosts";
echo "[-] Collected $subjack Takeovers"
echo "[-] Collected Nuclei Output"

echo ""
echo "[-] Finished reconasha.sh"
