#!/bin/bash

# Nuge App - Development Cleanup Script
# This script stops all development services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[NUGE-CLEANUP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[NUGE-CLEANUP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[NUGE-CLEANUP]${NC} $1"
}

print_error() {
    echo -e "${RED}[NUGE-CLEANUP]${NC} $1"
}

# Detect Docker Compose command
detect_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null; then
        echo "docker compose"
    else
        echo ""
    fi
}

# Stop Supabase
stop_supabase() {
    print_status "Stopping Supabase..."
    
    if npx supabase status --format json &> /dev/null; then
        local status=$(npx supabase status --format json 2>/dev/null | jq -r '.[] | select(.name == "API") | .status' 2>/dev/null || echo "unknown")
        if [ "$status" = "RUNNING" ]; then
            npx supabase stop
            if [ $? -eq 0 ]; then
                print_success "Supabase stopped successfully"
            else
                print_error "Failed to stop Supabase"
            fi
        else
            print_warning "Supabase was not running"
        fi
    else
        print_warning "Supabase was not running"
    fi
}

# Stop Redis
stop_redis() {
    print_status "Stopping Redis container..."
    
    DOCKER_COMPOSE_CMD=$(detect_docker_compose)
    if [ -z "$DOCKER_COMPOSE_CMD" ]; then
        print_error "Docker Compose is not available"
        return 1
    fi
    
    if $DOCKER_COMPOSE_CMD ps redis | grep -q "Up"; then
        $DOCKER_COMPOSE_CMD stop redis
        if [ $? -eq 0 ]; then
            print_success "Redis stopped successfully"
        else
            print_error "Failed to stop Redis"
        fi
    else
        print_warning "Redis was not running"
    fi
}

# Optional: Remove Redis container and volumes
cleanup_redis() {
    if [ "$1" = "--clean" ]; then
        print_status "Cleaning up Redis container and volumes..."
        DOCKER_COMPOSE_CMD=$(detect_docker_compose)
        if [ -n "$DOCKER_COMPOSE_CMD" ]; then
            $DOCKER_COMPOSE_CMD down redis
            docker volume prune -f
            print_success "Redis cleanup completed"
        else
            print_error "Docker Compose is not available for cleanup"
        fi
    fi
}

# Display cleanup information
show_cleanup_info() {
    print_success "Development services stopped!"
    echo ""
    echo -e "${BLUE}ℹ️  Service Status:${NC}"
    echo -e "  ${YELLOW}Redis:${NC} Stopped"
    echo -e "  ${YELLOW}Supabase:${NC} Stopped"
    echo ""
    echo -e "${BLUE}💡 Tips:${NC}"
    echo -e "  • To start services again: ${YELLOW}npm run dev:setup${NC}"
    echo -e "  • To clean Redis volumes: ${YELLOW}npm run dev:stop -- --clean${NC}"
    echo ""
}

# Main execution
main() {
    print_status "Cleaning up Nuge development environment..."
    
    stop_supabase
    stop_redis
    cleanup_redis "$1"
    show_cleanup_info
}

# Handle script interruption
trap 'print_error "Cleanup interrupted"; exit 1' INT TERM

# Run main function
main "$@" 