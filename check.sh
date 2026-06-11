#!/bin/bash

show_menu() {
    echo "============================="
    echo "        МЕНЮ МОДУЛЕЙ         "
    echo "============================="
    echo "1) Модуль 1"
    echo "2) Модуль 2"
    echo "3) Модуль 3"
    echo "4) Все модули"
    echo "5) Выход"
    echo "-----------------------------"
}

check() {
    local module=$1
    local id=$2
    local name=$3
    local vm=$4
    local command=$5
    local expected_pattern=$6
    
    echo -n "  М$module.$id: $name ... "
    
    local output=$(exec_on_vm "$vm" "$command")
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

                if (( $vm == "ISP" && $module == 2)); then
                    qm guest exec 200 -- apt install curl -y
                fi
                
                IFS='|' read -ra PATTERNS <<< "$expected_pattern"

                CHECK_FAILED=0
                HAVE_FAILED=0
                echo -e ""
                echo -e "-----------------------------------------------"
                for pat in "${PATTERNS[@]}"; do
                    if ! grep -iE -q "$pat" <<< "$output"; then
                        CHECK_FAILED=1
                    fi
                    if [ $CHECK_FAILED -eq 0 ]; then
                        echo -e "$pat : ${GREEN}СДЕЛАНО${NC}"
                        PASSED_CHECKS=$((PASSED_CHECKS + 1))
                    else
                        echo -e "$pat : ${RED}НЕ СДЕЛАНО${NC}"
                        CHECK_FAILED=0
                        HAVE_FAILED=1
                    fi
                done
                if [ $HAVE_FAILED -eq 1 ]; then
                    echo -e "Команда: $command"
                    echo -e "Вывод: $output"
                    read -p "Продолжить ?"
                fi
                echo "[M$module.$id] $name: Проверенно" >> "$REPORT_FILE"
                echo " Команда: $command" >> "$REPORT_FILE"
                echo " Ожидалось: $expected_pattern" >> "$REPORT_FILE"
                echo " Получено: $output" >> "$REPORT_FILE"
                echo -e "-----------------------------------------------"
}

show_statistics() {
    echo -e "\n${BLUE}======================================================${NC}"
    echo -e "${BLUE}   СТАТИСТИКА${NC}"
    echo -e "${BLUE}======================================================${NC}\n"
    
    local percentage=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    
    echo "  Всего проверок: $TOTAL_CHECKS"
    echo -e "  ${GREEN}Выполнено: $PASSED_CHECKS${NC}"
    echo -e "  ${RED}Не выполнено: $((TOTAL_CHECKS - PASSED_CHECKS))${NC}"
    echo "  Процент выполнения: $percentage%"
    
    echo -e "\n${BLUE}======================================================${NC}\n"
    
    if [ $percentage -ge 85 ]; then
        echo -e "${GREEN}  РЕЗУЛЬТАТ: ЭКЗАМЕН СДАН (ОТЛИЧНО)${NC}"
    elif [ $percentage -ge 70 ]; then
        echo -e "${GREEN}  РЕЗУЛЬТАТ: ЭКЗАМЕН СДАН (ХОРОШО)${NC}"
    elif [ $percentage -ge 50 ]; then
        echo -e "${YELLOW}  РЕЗУЛЬТАТ: ЭКЗАМЕН СДАН (УДОВЛЕТВОРИТЕЛЬНО)${NC}"
    else
        echo -e "${RED}  РЕЗУЛЬТАТ: ЭКЗАМЕН НЕ СДАН${NC}"
    fi
    
    echo -e "\n${BLUE}======================================================${NC}"
}
exec_on_vm() {
    local vm_name=$1
    local command=$2
    local vm_id=${VM_IDS[$vm_name]}
    
    if [ -z "$vm_id" ]; then
        echo "ERROR: Unknown VM $vm_name"
        return 1
    fi
    
    # Выполняем команду через qm guest exec
    local output=$(qm guest exec "$vm_id" -- bash -c "$command" 2>/dev/null | grep -o '"out-data":"[^"]*"' | sed 's/"out-data":"//;s/"$//' | sed 's/\\n/\n/g')
    
    if [ -z "$output" ]; then
        output=$(qm guest exec "$vm_id" -- bash -c "$command" 2>&1 | grep -v "execution failed" | head -20)
    fi
    
    echo "$output"
}
