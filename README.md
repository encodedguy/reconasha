## reconasha
Let the reconasha do the automation for you.

## Installation
### Kali-Linux
Check /etc/apt/sources.list file for installation sources first.

``sudo apt-get update``

``sudo apt-get install golang python3 -y``

``sudo apt-get install amass httpx nuclei subfinder assetfinder -y``

``Install subjack, gau from official repository``

``export SHODANAPIKEY=<YOUR-API-KEY>``

``git clone https://github.com/encodedguy/reconasha``

``cd reconasha``

## Usage
``chmod +x reconasha.sh``

``./reconasha.sh domains.txt``
