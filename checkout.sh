#!/bin/bash
# ============================================================
# Скрипт проверки экзамена Са-405 (без оценки баллов)
# Просто показывает: СДЕЛАНО / НЕ СДЕЛАНО
# ============================================================
source ./check.sh
# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ------------------------------------------------------------
# Конфигурация
# ------------------------------------------------------------
REPORT_FILE="exam_check_report_$(date +%Y%m%d_%H%M%S).txt"
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Список ВМ (ID, имя)
declare -A VM_IDS=(
    ["ISP"]=100
    ["HQ-RTR"]=101
    ["BR-RTR"]=102
    ["HQ-SRV"]=103
    ["BR-SRV"]=104
    ["HQ-CLI"]=105
)

# ------------------------------------------------------------
# Функции
# ------------------------------------------------------------

# Выполнить команду на ВМ через guest-agent


# Проверка критерия (просто выводит результат)

# ------------------------------------------------------------
# МОДУЛЬ 1
# ------------------------------------------------------------
check_module1() {
    echo -e "\n${BLUE}========== МОДУЛЬ 1: Базовая инфраструктура ==========${NC}\n"
    
    check 1 1.ISP "Базовая настройка (FQDN, IP, часовой пояс)" "ISP" \
        "hostname 2>/dev/null; ip a 2>/dev/null | grep -E 'inet (10|172|192)'; timedatectl 2>/dev/null | grep 'Time zone'" \
        "isp.au-team.irpo|inet 172|Asia/Yekaterinburg"
    check 1 1.HQ-RTR "Базовая настройка (FQDN, IP, часовой пояс)" "HQ-RTR" \
        "hostname 2>/dev/null; ip a 2>/dev/null | grep -E 'inet (10|172|192)'; timedatectl 2>/dev/null | grep 'Time zone'" \
        "hq-rtr.au-team.irpo|inet 172|inet 192|Asia/Yekaterinburg"
    check 1 1.BR-RTR "Базовая настройка (FQDN, IP, часовой пояс)" "BR-RTR" \
        "hostname 2>/dev/null; ip a 2>/dev/null | grep -E 'inet (10|172|192)'; timedatectl 2>/dev/null | grep 'Time zone'" \
        "br-rtr.au-team.irpo|inet 172|inet 192|Asia/Yekaterinburg"
    check 1 1.HQ-SRV "Базовая настройка (FQDN, IP, часовой пояс)" "HQ-SRV" \
        "hostname 2>/dev/null; ip a 2>/dev/null | grep -E 'inet (10|172|192)'; timedatectl 2>/dev/null | grep 'Time zone'" \
        "hq-srv.au-team.irpo|inet 192|Asia/Yekaterinburg"
    check 1 1.BR-SRV "Базовая настройка (FQDN, IP, часовой пояс)" "BR-SRV" \
        "hostname 2>/dev/null; ip a 2>/dev/null | grep -E 'inet (10|172|192)'; timedatectl 2>/dev/null | grep 'Time zone'" \
        "br-srv.au-team.irpo|inet 192|Asia/Yekaterinburg"
    check 1 1.HQ-CLI "Базовая настройка (FQDN, IP, часовой пояс)" "HQ-CLI" \
        "hostname 2>/dev/null; ip a 2>/dev/null | grep -E 'inet (10|172|192)'; timedatectl 2>/dev/null | grep 'Time zone'" \
        "hq-cli.au-team.irpo|Asia/Yekaterinburg"

       check 1 2.ISP "Доступ в Интернет (DHCP, NAT)" "ISP" \
        "iptables-save 2>/dev/null | grep POSTROUTING; cat /etc/network/interfaces 2>/dev/null | grep -i 'iface eth0 inet dhcp'" \
        "iface eth0 inet dhcp|POSTROUTING"
       check 1 2.HQ-RTR "Доступ в Интернет (NAT)" "HQ-RTR" \
        "iptables-save 2>/dev/null | grep POSTROUTING" \
        "POSTROUTING"
       check 1 2.BR-RTR "Доступ в Интернет (NAT)" "BR-RTR" \
        "iptables-save 2>/dev/null | grep POSTROUTING" \
        "POSTROUTING"
      
    check 1 3.BR-RTR "Учетные записи (net_admin, UID 2026)" "BR-RTR" \
            "grep 'net_admin' /etc/passwd 2>/dev/null; sudo -l -U net_admin 2>/dev/null | grep 'NOPASSWD'" \
        "net_admin|NOPASSWD"
    
    check 1 3.HQ-RTR "Учетные записи (net_admin, UID 2026)" "HQ-RTR" \
            "grep 'net_admin' /etc/passwd 2>/dev/null; sudo -l -U net_admin 2>/dev/null | grep 'NOPASSWD'" \
        "net_admin|NOPASSWD"

    check 1 3.HQ-SRV "Учетные записи (sshuser, net_admin, UID 2026)" "HQ-SRV" \
        "id sshuser 2>/dev/null | grep -E 'uid=2026'; grep 'sshuser' /etc/passwd 2>/dev/null; sudo -l -U sshuser 2>/dev/null | grep 'NOPASSWD'" \
        "uid=2026|sshuser|NOPASSWD"
    
    check 1 3.BR-SRV "Учетные записи (sshuser, net_admin, UID 2026)" "BR-SRV" \
        "id sshuser 2>/dev/null | grep -E 'uid=2026'; grep 'sshuser' /etc/passwd 2>/dev/null; sudo -l -U sshuser 2>/dev/null | grep 'NOPASSWD'" \
        "uid=2026|sshuser|NOPASSWD"

    check 1 4 "Коммутация (VLAN 100,200,999, Router-on-a-Stick)" "HQ-RTR" \
        "ip link show type vlan 2>/dev/null |grep -E '100|200|999'; ip a 2>/dev/null | grep -E '100|200|999'" \
        "100|200|999"
     
    check 1 5.HQ-SRV "Безопасный SSH (порт 2026, только sshuser, баннер)" "HQ-SRV" \
        "grep -iE '^Port 2026|^AllowUsers sshuser|^Banner|^MaxAuthTries' /etc/openssh/sshd_config 2>/dev/null; cat /etc/issue.net 2>/dev/null | grep -i 'authorized'" \
        "Port 2026|AllowUsers sshuser|MaxAuthTries 2|Banner"
    
    check 1 5.BR-SRV "Безопасный SSH (порт 2026, только sshuser, баннер)" "BR-SRV" \
        "grep -iE '^Port 2026|^AllowUsers sshuser|^Banner|^MaxAuthTries' /etc/openssh/sshd_config 2>/dev/null; cat /etc/issue.net 2>/dev/null | grep -i 'authorized'" \
        "Port 2026|AllowUsers sshuser|MaxAuthTries 2|Banner"
     
    check 1 6.HQ-RTR "IP-туннелирование (GRE или IPinIP)" "HQ-RTR" \
        "ip tunnel show 2>/dev/null | grep -E 'gre|ipip'; ping 10.0.0.2 -c 2 2>/dev/null | grep ', 0% packet loss'" \
        "gre|0% packet loss"
    

    check 1 6.BR-RTR "IP-туннелирование (GRE или IPinIP)" "BR-RTR" \
        "ip tunnel show 2>/dev/null | grep -E 'gre|ipip'; ping 10.0.0.1 -c 2 2>/dev/null | grep ', 0% packet loss'" \
        "gre|0% packet loss"
     
    check 1 7.HQ-RTR "Динамическая маршрутизация OSPF" "HQ-RTR" \
        "vtysh -c 'show ip ospf route' 2>/dev/null | grep -iE 'via.*gre'; vtysh -c 'show run' 2>/dev/null | grep -iE 'network|ip ospf|passive-interface'" \
        "ospf|gre|passive-interface|authentication"

    check 1 7.BR-RTR "Динамическая маршрутизация OSPF" "BR-RTR" \
        "vtysh -c 'show ip ospf route' 2>/dev/null | grep -iE 'via.*gre'; vtysh -c 'show run' 2>/dev/null | grep -iE 'network|ip ospf|passive-interface'" \
        "ospf|gre|passive-interface|authentication"
    
    check 1 8 "Служба DHCP" "HQ-RTR" \
        "systemctl status isc-dhcp-server 2>/dev/null || systemctl status dhcpd 2>/dev/null; grep -E 'range|option domain-name' /etc/dhcp/dhcpd.conf 2>/dev/null; cat /etc/dhcp/dhcpd.conf | grep 'au-team.irpo|option routers|option domain-name-servers'" \
        "active|range|domain-name"
    
    check 1 9 "Инфраструктура DNS (прямой/обратный просмотр, форвардинг)" "HQ-SRV" \
        "ping hq-rtr.au-team.irpo -c 1 2>/dev/null | grep 'icmp_seq'; grep 'server' /etc/dnsmasq.conf" \
        "server|icmp_seq"
    
    check 1 10 "Оформление отчета (документ в корне)" "" \
        "test -f /root/*Соколов*Модуль1.docx || test -f /home/*Соколов*Модуль1.docx || find / -name '*Соколов*Модуль1.docx' 2>/dev/null | head -1" \
        "Соколов|Модуль1"
}

# ------------------------------------------------------------
# МОДУЛЬ 2
# ------------------------------------------------------------
#

check_module2() {
    echo -e "\n${BLUE}========== МОДУЛЬ 2: Сервисы и автоматизация ==========${NC}\n"
    
    check 2 1 "Контроллер домена Samba DC" "BR-SRV" \
        "samba-tool domain info 2>/dev/null | grep 'au-team.irpo'; wbinfo -u 2>/dev/null | head -5" \
        "AU-TEAM"
    
    check 2 2 "Пользователи, группы и sudo (hquser1-5, группа hq)" "HQ-CLI" \
        "samba-tool user list 2>/dev/null | grep -E 'hquser[1-5]'; getent group hq 2>/dev/null; sudo -l -U hquser1 | grep -E 'cat|grep|id'; stat -c '%a %n' /usr/bin/sudo" \
        "hquser1|hquser2|hquser3|hquser4|hquser5|hq|grep|id|cat|4755"
    
    check 2 3 "Дисковый массив RAID 0 (/dev/md0, монтирование /raid)" "HQ-SRV" \
        "mdadm --detail /dev/md0 2>/dev/null | grep 'Raid Level : raid0'; lsblk 2>/dev/null | grep md0; grep '/raid' /etc/fstab 2>/dev/null" \
        "raid0|md0|/raid"
    
    check 2 4.HQ-SRV "NFS и Automount" "HQ-SRV" \
        "showmount -e localhost 2>/dev/null | grep '/raid/nfs'" \
        "/raid/nfs"
    
    check 2 4.HQ-CLI "NFS и Automount" "HQ-CLI" \
        "df -h 2>/dev/null | grep '/raid/nfs'" \
        "/raid/nfs|2,0G"
    
    check 2 5.HQ-SRV "Служба времени Chrony" "HQ-SRV" \
         "chronyc tracking 2>/dev/null | grep 'Stratum' | grep 6; chronyc tracking | grep '172.16'" \
        "Stratum|6|172.16"
    
        check 2 5.HQ-CLI "Служба времени Chrony" "HQ-CLI" \
        "chronyc tracking 2>/dev/null | grep 'Stratum' | grep 6; chronyc tracking | grep '172.16'" \
        "Stratum|6|172.16"
    
        check 2 5.BR-RTR "Служба времени Chrony" "BR-RTR" \
        "chronyc tracking 2>/dev/null | grep 'Stratum' | grep 6; chronyc tracking | grep '172.16'" \
        "Stratum|6|172.16"

        check 2 5.BR-SRV "Служба времени Chrony" "BR-SRV" \
         "chronyc tracking 2>/dev/null | grep 'Stratum' | grep 6; chronyc tracking | grep '172.16'" \
        "Stratum|6|172.16"

        check 2 6 "Автоматизация Ansible" "BR-SRV" \
        "/usr/bin/ansible all -m ping | grep -iE 'hq-rtr|br-rtr|hq-srv|hq-cli.*SUCCESS'" \
        "hq-srv|hq-cli|hq-rtr|br-rtr|SUCCESS"
    
    check 2 7 "Контейнеризация Docker (testapp + db)" "BR-SRV" \
        "docker ps 2>/dev/null | grep -E 'testapp|db'; curl http://localhost:8080 | grep '/html'" \
        "testapp|db|html"
    
    check 2 8 "Веб-приложение LAMP (Apache + MariaDB)" "HQ-SRV" \
        "systemctl status httpd2 2>/dev/null | grep -i active; mysql -u root -e 'show databases;' 2>/dev/null | grep 'webdb'" \
        "active|webdb"
    
    check 2 9.HQ-RTR "Проброс портов DNAT (8080, 2026)" "HQ-RTR" \
        "iptables-save 2>/dev/null | grep -E 'DNAT'" \
        "172.16.1.2|dport 8080|dport 2026|:80|:2026"
        
    check 2 9.BR-RTR "Проброс портов DNAT (8080, 2026)" "BR-RTR" \
        "iptables-save 2>/dev/null | grep -E 'DNAT'" \
        "172.16.2.2|dport 8080|dport 2026|:8080|:2026"
    
    check 2 10 "Reverse Proxy Nginx с HTTP Basic Auth" "ISP" \
        "curl -u WEB:P@Sssw0rd http://172.16.1.2:8080 2>/dev/null | grep ''DemoTest" \
        "DemoTest"
    
    check 2 11 "Установка Яндекс.Браузера" "HQ-CLI" \
        "dpkg -l 2>/dev/null | grep -i yandex || rpm -qa 2>/dev/null | grep -i yandex || test -f '/opt/yandex/browser/yandex-browser' && echo 'found'" \
        "found|yandex"
}

# ------------------------------------------------------------
# МОДУЛЬ 3
# ------------------------------------------------------------
check_module3() {
    echo -e "\n${BLUE}========== МОДУЛЬ 3: Безопасность и мониторинг ==========${NC}\n"
    
    check 3 1 "Импорт пользователей из CSV" "HQ-SRV" \
        "samba-tool user list 2>/dev/null | grep -E 'hquser[1-5]'" \
        "hquser[1-5]"
    
    check 3 2 "Центр сертификации CA (ГОСТ, срок 30 дней)" "HQ-SRV" \
        "openssl x509 -in /etc/ssl/certs/ca.crt -text 2>/dev/null | grep -E 'Subject:|Issuer:'" \
        "Subject:|Issuer:"
    
    check 3 3 "HTTPS для web.au-team.irpo" "ISP" \
        "nginx -T 2>/dev/null | grep -E 'ssl_certificate|ssl_protocols'" \
        "ssl_certificate"
    
    check 3 4 "Защищенный туннель IPsec + GRE" "HQ-RTR" \
        "ip xfrm state 2>/dev/null | grep -E 'enc|auth'" \
        "enc|auth"
    
    check 3 5 "Межсетевой экран (разрешены HTTP, HTTPS, DNS, NTP, ICMP, ESP)" "ISP" \
        "nft list ruleset 2>/dev/null | grep -E 'tcp dport (80|443|53)|udp dport (53|123)|esp'" \
        "80|443|53|123|esp"
    
    check 3 6 "Сервер печати CUPS (PDF-принтер)" "HQ-SRV" \
        "lpstat -p 2>/dev/null | grep -E 'printer|PDF'; systemctl status cups 2>/dev/null | grep -i active" \
        "printer|PDF|active"
    
    check 3 7 "Логирование и ротация (rsyslog, logrotate)" "HQ-SRV" \
        "grep -E 'weekly|size 10M|compress' /etc/logrotate.d/rsyslog 2>/dev/null" \
        "weekly|10M|compress"
    
    check 3 8 "Мониторинг Zabbix (mon.au-team.irpo)" "HQ-SRV" \
        "systemctl status zabbix-server 2>/dev/null | grep -i active" \
        "active"
    
    check 3 9 "Fail2ban (бан после 3 попыток) + Ansible inventory" "HQ-SRV" \
        "fail2ban-client status sshd 2>/dev/null | grep -E 'Banned IP list'" \
        "Banned"
    
    check 3 10 "Резервное копирование (Cyber Backup)" "HQ-CLI" \
        "ls -la /backup 2>/dev/null | grep -E 'etc|webdb'" \
        "etc|webdb"
}

# ------------------------------------------------------------
# Проверка доступности ВМ
# ------------------------------------------------------------
check_vm_availability() {
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${BLUE}   Проверка доступности виртуальных машин${NC}"
    echo -e "${BLUE}======================================================${NC}\n"
    
    for vm_name in "${!VM_IDS[@]}"; do
        local vm_id=${VM_IDS[$vm_name]}
        local status=$(qm status "$vm_id" 2>/dev/null | grep -o "status: [a-z]*" | cut -d' ' -f2)
        
        printf "  %-10s (ID: %-3d) -> " "$vm_name" "$vm_id"
        
        if [ "$status" != "running" ]; then
            echo -e "${RED}❌ НЕ ЗАПУЩЕНА${NC}"
        else
            # Проверяем guest-agent
            qm agent "$vm_id" ping 2>/dev/null >/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ ЗАПУЩЕНА, guest-agent OK${NC}"
            else
                echo -e "${YELLOW}⚠️ ЗАПУЩЕНА, но guest-agent НЕ ОТВЕЧАЕТ${NC}"
            fi
        fi
    done
    echo ""
}

# ------------------------------------------------------------
# Вывод статистики
# ------------------------------------------------------------
# ------------------------------------------------------------
# Главная функция
# ------------------------------------------------------------
main() {
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${BLUE}   Экзаменационная проверка Са-405${NC}"
    echo -e "${BLUE}   Дата: $(date)${NC}"
    echo -e "${BLUE}======================================================${NC}"
    
    echo "Экзаменационная проверка Са-405" > "$REPORT_FILE"
    echo "Дата: $(date)" >> "$REPORT_FILE"
    echo "======================================================" >> "$REPORT_FILE"
    
    check_vm_availability

    show_menu
    read -p "Выберите Модуль: " choice
    
    case $choice in
        1)
            check_module1
            ;;
        2)
            declare -A VM_IDS=(
                ["ISP"]=200
                ["HQ-RTR"]=201
                ["BR-RTR"]=202
                ["HQ-SRV"]=203
                ["BR-SRV"]=204
                ["HQ-CLI"]=205
            )
            check_module2
            ;;
        3)
            declare -A VM_IDS=(
                ["ISP"]=200
                ["HQ-RTR"]=201
                ["BR-RTR"]=202
                ["HQ-SRV"]=203
                ["BR-SRV"]=204
                ["HQ-CLI"]=205
            )
            check_module3
            ;;
        4)
            check_module1
        declare -A VM_IDS=(
            ["ISP"]=200
            ["HQ-RTR"]=201
            ["BR-RTR"]=202
            ["HQ-SRV"]=203
            ["BR-SRV"]=204
            ["HQ-CLI"]=205
        )
            check_module2
            ;;
    esac
    
    show_statistics
    
    echo -e "\n${GREEN}Подробный отчет сохранен в: $REPORT_FILE${NC}\n"
}

# Запуск
main
