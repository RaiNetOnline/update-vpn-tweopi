#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${2}${1}${NC}"
}

check_commands() {
    local commands=("docker" "docker-compose" "git")
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_message "Ошибка: Команда $cmd не найдена. Убедитесь, что Docker и Git установлены." "$RED"
            exit 1
        fi
    done
}

install_project() {
    print_message "Установка проекта..." "$BLUE"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    print_message "Выберите проект для установки:" "$CYAN"
    echo "1) 3xui-shopbot"
    echo "2) remnawave-shopbot"
    echo "3) Назад"
    
    read -p "Выберите вариант [1-3]: " install_choice
    
    case $install_choice in
        1)
            PROJECT_NAME="3xui-shopbot"
            GIT_URL="https://github.com/tweopi/3xui-shopbot"
            ;;
        2)
            PROJECT_NAME="remnawave-shopbot"
            GIT_URL="https://github.com/tweopi/remnawave-shopbot"
            ;;
        3)
            return
            ;;
        *)
            print_message "Неверный выбор" "$RED"
            return 1
            ;;
    esac
    
    if [ -d "$SCRIPT_DIR/$PROJECT_NAME" ]; then
        print_message "Проект $PROJECT_NAME уже установлен!" "$YELLOW"
        read -p "Хотите переустановить? (y/N): " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            return
        fi
        print_message "Удаляем существующую директорию..." "$YELLOW"
        rm -rf "$SCRIPT_DIR/$PROJECT_NAME"
    fi
    
    print_message "Клонируем репозиторий $GIT_URL..." "$YELLOW"
    if git clone "$GIT_URL" "$SCRIPT_DIR/$PROJECT_NAME"; then
        print_message "Проект успешно клонирован!" "$GREEN"
        
        if [ -f "$SCRIPT_DIR/$PROJECT_NAME/docker-compose.yml" ]; then
            cd "$SCRIPT_DIR/$PROJECT_NAME" || {
                print_message "Ошибка: Не удалось перейти в директорию проекта" "$RED"
                return 1
            }
            
            print_message "Запускаем Docker Compose..." "$YELLOW"
            docker-compose up -d
            
            if [ $? -eq 0 ]; then
                print_message "Проект $PROJECT_NAME успешно установлен и запущен!" "$GREEN"
            else
                print_message "Ошибка при запуске Docker Compose" "$RED"
            fi
            
            cd "$SCRIPT_DIR" || return 1
        else
            print_message "Docker Compose файл не найден. Проверьте документацию проекта." "$YELLOW"
        fi
    else
        print_message "Ошибка при клонировании репозитория" "$RED"
        return 1
    fi
}

update_project() {
    print_message "Обновление проекта..." "$BLUE"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    print_message "Текущая директория: $SCRIPT_DIR" "$YELLOW"
    
    projects_found=0
    
    if [ -d "$SCRIPT_DIR/3xui-shopbot" ]; then
        print_message "Найден проект 3xui-shopbot" "$GREEN"
        cd "$SCRIPT_DIR/3xui-shopbot" || {
            print_message "Ошибка: Не удалось перейти в директорию 3xui-shopbot" "$RED"
            return 1
        }
        
        print_message "Останавливаем контейнеры..." "$YELLOW"
        docker-compose down
        
        print_message "Пересобираем образы..." "$YELLOW"
        docker-compose build --no-cache
        
        print_message "Запускаем контейнеры..." "$YELLOW"
        docker-compose up -d
        
        if [ $? -eq 0 ]; then
            print_message "Проект 3xui-shopbot успешно обновлен и запущен!" "$GREEN"
        else
            print_message "Ошибка при обновлении проекта 3xui-shopbot" "$RED"
        fi
        
        projects_found=$((projects_found + 1))
        cd "$SCRIPT_DIR" || return 1
    fi
    
    if [ -d "$SCRIPT_DIR/remnawave-shopbot" ]; then
        print_message "Найден проект remnawave-shopbot" "$GREEN"
        cd "$SCRIPT_DIR/remnawave-shopbot" || {
            print_message "Ошибка: Не удалось перейти в директорию remnawave-shopbot" "$RED"
            return 1
        }
        
        print_message "Останавливаем контейнеры..." "$YELLOW"
        docker-compose down
        
        print_message "Пересобираем образы..." "$YELLOW"
        docker-compose build --no-cache
        
        print_message "Запускаем контейнеры..." "$YELLOW"
        docker-compose up -d
        
        if [ $? -eq 0 ]; then
            print_message "Проект remnawave-shopbot успешно обновлен и запущен!" "$GREEN"
        else
            print_message "Ошибка при обновлении проекта remnawave-shopbot" "$RED"
        fi
        
        projects_found=$((projects_found + 1))
        cd "$SCRIPT_DIR" || return 1
    fi
    
    if [ $projects_found -eq 0 ]; then
        print_message "Не найдены проекты 3xui-shopbot или remnawave-shopbot в текущей директории" "$RED"
        print_message "Хотите установить проекты? (y/N): " "$YELLOW"
        read -p "" install_choice
        if [[ $install_choice =~ ^[Yy]$ ]]; then
            install_project
        fi
        return 1
    fi
    
    print_message "Обновление завершено!" "$GREEN"
}

show_status() {
    print_message "Статус проектов:" "$BLUE"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    projects_found=0
    
    if [ -d "$SCRIPT_DIR/3xui-shopbot" ]; then
        print_message "Проверка статуса 3xui-shopbot..." "$YELLOW"
        cd "$SCRIPT_DIR/3xui-shopbot" && docker-compose ps
        cd "$SCRIPT_DIR" || return 1
        projects_found=$((projects_found + 1))
    fi
    
    if [ -d "$SCRIPT_DIR/remnawave-shopbot" ]; then
        print_message "Проверка статуса remnawave-shopbot..." "$YELLOW"
        cd "$SCRIPT_DIR/remnawave-shopbot" && docker-compose ps
        cd "$SCRIPT_DIR" || return 1
        projects_found=$((projects_found + 1))
    fi
    
    if [ $projects_found -eq 0 ]; then
        print_message "Проекты не найдены" "$RED"
    fi
}

show_logs() {
    print_message "Выберите проект для просмотра логов:" "$BLUE"
    echo "1) 3xui-shopbot"
    echo "2) remnawave-shopbot"
    echo "3) Назад"
    
    read -p "Выберите вариант [1-3]: " log_choice
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    case $log_choice in
        1)
            if [ -d "$SCRIPT_DIR/3xui-shopbot" ]; then
                cd "$SCRIPT_DIR/3xui-shopbot" && docker-compose logs -f
                cd "$SCRIPT_DIR" || return 1
            else
                print_message "Проект 3xui-shopbot не найден" "$RED"
            fi
            ;;
        2)
            if [ -d "$SCRIPT_DIR/remnawave-shopbot" ]; then
                cd "$SCRIPT_DIR/remnawave-shopbot" && docker-compose logs -f
                cd "$SCRIPT_DIR" || return 1
            else
                print_message "Проект remnawave-shopbot не найден" "$RED"
            fi
            ;;
        3)
            return
            ;;
        *)
            print_message "Неверный выбор" "$RED"
            ;;
    esac
}

main_menu() {
    while true; do
        echo
        print_message "=== Меню управления проектами ===" "$BLUE"
        echo "1) Установить проект"
        echo "2) Обновить проект"
        echo "3) Показать статус контейнеров"
        echo "4) Показать логи"
        echo "5) Выход"
        echo "6) Информация для купивших платный скрипт"
        echo
        
        read -p "Выберите действие [1-5]: " choice
        
        case $choice in
            1)
                install_project
                ;;
            2)
                update_project
                ;;
            3)
                show_status
                ;;
            4)
                show_logs
                ;;
            5)
                print_message "Выход..." "$GREEN"
                exit 0
                ;;
            6)
                print_message "Вы должны перекинуть вручную файлы с приватного канала и запустить данные скрипт после чего он обновится, разработчик update файла RaiNet (Евгений)" "$GREEN"
                exit 0
                ;;
            *)
                print_message "Неверный выбор. Пожалуйста, выберите от 1 до 5." "$RED"
                ;;
        esac
        
        echo
        read -p "Нажмите Enter чтобы продолжить..."
    done
}

main() {
    print_message "Установщик проектов" "$BLUE"
    print_message "Текущая директория: $(pwd)" "$YELLOW"
    
    # Проверяем наличие необходимых команд
    check_commands
    
    # Запускаем главное меню
    main_menu
}

trap 'echo -e "\n${RED}Прервано пользователем${NC}"; exit 1' INT

main