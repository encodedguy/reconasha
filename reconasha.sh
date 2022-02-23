amass enum -noalts -nolocaldb -df domains.txt -min-for-recursive 7 -passive -o subdomains-amass-passive.txt & subfinder -dL domains.txt -silent -nC -nW -o subdomains-subfinder.txt -t 100
cat domains.txt | assetfinder --subs-only | tee subdomains-assetfinder.txt
cat domains.txt | parallel -j 10 ~/go/bin/crobat -s {} 2> /dev/null | tee subdomains-crobat.txt
cat domains.txt | ~/go/bin/haktrails subdomains | tee subdomains-haktrails.txt
cat domains.txt | parallel -j 10 shosubgo -d {} -s $SHODANAPIKEY 2> /dev/null | tee subdomains-shosubgo.txt
cat subdomains-* | sort -u | tee subdomains.txt
cat subdomains.txt | httpx -sc -server -title -ip -cname -silent -threads 100 -o httpx.txt & subjack -w subdomains.txt -t 300 -o subjack.txt
cat httpx.txt | cut -d' ' -f1 | tee live.txt
mkdir nuclei; nuclei -silent -l live.txt -t cves -c 50 -o nuclei/cves.txt -rl 300
nuclei -l live.txt -silent -t exposures -t exposed-panels -rl 300 -c 50 -o nuclei/exposures_exposed-panels.txt
nuclei -l live.txt -silent -t misconfiguration -rl 300 -c 50 -o nuclei/misconfiguration.txt
nuclei -l live.txt -silent -t takeovers -t default-logins -rl 300 -c 50 -o nuclei/takeovers_default-logins.txt
echo subdomains.txt | gau | tee gau-output.txt
