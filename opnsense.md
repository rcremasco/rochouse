
con il plugin nginx configurato come reverse proxy su home assistant, non funziona l'integrazione con Alexa, 
perchè il template di dafault aggiunge un check su $http_user_agent escludendo anche python-requests che usa appnto l'integrazione

editare il file /usr/local/opnsense/service/templates/OPNsense/Nginx/http.conf e rimuovere python-agent del codice:

    if ($http_user_agent ~* Python-urllib|Nmap|libwww-perl|MJ12bot|Jorgee|fasthttp|libwww|Telesphoreo|A6-Indexer|ltx71|okhttp|ZmEu|sqlma
p|LMAO/2.0|l9explore|l9tcpid|Masscan|zgrab|Ronin/2.0|Hakai/2.0) {

