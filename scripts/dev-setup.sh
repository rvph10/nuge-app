#!/bin/bash

# Nuge App - Development Setup Script
# This script sets up all necessary services for local development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[NUGE-DEV]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[NUGE-DEV]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[NUGE-DEV]${NC} $1"
}

print_error() {
    echo -e "${RED}[NUGE-DEV]${NC} $1"
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

# Check if required tools are installed
check_dependencies() {
    print_status "Checking development dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker and try again."
        exit 1
    fi
    
    DOCKER_COMPOSE_CMD=$(detect_docker_compose)
    if [ -z "$DOCKER_COMPOSE_CMD" ]; then
        print_error "Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi
    
    if ! command -v npx &> /dev/null; then
        print_error "Node.js/npm is not installed. Please install Node.js and try again."
        exit 1
    fi
    
    print_success "All dependencies are available (using: $DOCKER_COMPOSE_CMD)"
}

# Start Redis with Docker Compose
start_redis() {
    print_status "Starting Redis container..."
    
    if $DOCKER_COMPOSE_CMD ps redis | grep -q "Up"; then
        print_warning "Redis is already running"
    else
        $DOCKER_COMPOSE_CMD up -d redis
        if [ $? -eq 0 ]; then
            print_success "Redis started successfully"
        else
            print_error "Failed to start Redis"
            exit 1
        fi
    fi
}

# Start Supabase
start_supabase() {
    print_status "Starting Supabase..."
    
    # Check if Supabase is already running
    if npx supabase status --format json &> /dev/null; then
        local status=$(npx supabase status --format json 2>/dev/null | jq -r '.[] | select(.name == "API") | .status' 2>/dev/null || echo "unknown")
        if [ "$status" = "RUNNING" ]; then
            print_warning "Supabase is already running"
            return 0
        fi
    fi
    
    npx supabase start
    if [ $? -eq 0 ]; then
        print_success "Supabase started successfully"
    else
        print_error "Failed to start Supabase"
        exit 1
    fi
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for Redis
    local redis_retries=30
    while [ $redis_retries -gt 0 ]; do
        if $DOCKER_COMPOSE_CMD exec -T redis redis-cli ping &> /dev/null; then
            print_success "Redis is ready"
            break
        fi
        print_status "Waiting for Redis... ($redis_retries retries left)"
        sleep 1
        redis_retries=$((redis_retries - 1))
    done
    
    if [ $redis_retries -eq 0 ]; then
        print_warning "Redis may not be fully ready, but continuing..."
    fi
    
    # Supabase readiness is handled by the supabase start command
    print_success "Services are ready for development"
}

# Display service information
show_service_info() {
    print_status "Development environment is ready!"
    echo ""
    echo -e "${BLUE}📋 Service Information:${NC}"
    echo -e "  ${GREEN}Redis:${NC} redis://localhost:6379"
    echo -e "  ${GREEN}Supabase:${NC} Check 'npx supabase status' for details"
    echo ""
    echo -e "${BLUE}🚀 To start development:${NC}"
    echo -e "  Run: ${YELLOW}turbo run dev${NC}"
    echo ""
    echo -e "${BLUE}🛑 To stop services:${NC}"
    echo -e "  Run: ${YELLOW}npm run dev:stop${NC}"
    echo ""
}

# Main execution
main() {
    print_status "Setting up Nuge development environment..."
    
    check_dependencies
    start_redis
    start_supabase
    wait_for_services
    show_service_info
}

# Handle script interruption
trap 'print_error "Setup interrupted"; exit 1' INT TERM

# Run main function
main "$@" 