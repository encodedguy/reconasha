amass enum -noalts -nolocaldb -df domains.txt -min-for-recursive 7 -passive -o subdomains-amass-passive.txt & subfinder -dL domains.txt -silent -nC -nW -o subdomains-subfinder.txt -t 100
cat domains.txt | assetfinder --subs-only | tee subdomains-assetfinder.txt
cat subdomains-* | sort -u | tee subdomains.txt
cat subdomains.txt | httpx -sc -server -title -ip -cname -silent -threads 100 -o httpx.txt 
cat httpx.txt | cut -d' ' -f1 | tee live.txt
mkdir nuclei; nuclei -silent -l live.txt -t cves -o nuclei/cves.txt -rl 300
nuclei -l live.txt -silent -t exposures -rl 300 -o nuclei/exposures.txt
nuclei -l live.txt -silent -t exposed-panels -rl 300 -o nuclei/exposures.txt
nuclei -l live.txt -silent -t misconfiguration -rl 300 -o nuclei/misconfiguration.txt
nuclei -l live.txt -silent -t takeovers -rl 300 -o nuclei/takeovers.txt
nuclei -l live.txt -silent -t default-logins -rl 300 -o nuclei/default-logins.txt
