# democreator
## https://f4n1oms.github.io/democreator/
Если на Hq-srv, Hq-cli не работает интернет надо на hq-rtr прописать:
systemctl restart network 
systemctl restart dhcpd
#
Если не работает днс(bind) надо заново вставить его конфиг
