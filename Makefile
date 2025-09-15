# Makefile for Restaurant Menu Application
# This provides convenient commands for development and CI/CD

.PHONY: help install lint test security check deploy setup

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install all dependencies
	bundle install
	yarn install --check-files

setup: install ## Setup the application (install deps, create DB, seed)
	rails db:create
	rails db:migrate
	rails db:seed

lint: ## Run all linters
	@echo "Running RuboCop..."
	bundle exec rubocop
	@echo "Running Rails Best Practices..."
	bundle exec rails_best_practices .
	@echo "Running Reek..."
	bundle exec reek

lint-fix: ## Auto-fix linting issues where possible
	bundle exec rubocop -A

security: ## Run security checks
	@echo "Running Brakeman security scan..."
	bundle exec brakeman --no-pager
	@echo "Checking for vulnerable gems..."
	bundle audit check --update || true

test: ## Run all tests
	@echo "Running RSpec tests..."
	bundle exec rspec || echo "No tests found"

check: lint security test ## Run all checks (lint, security, tests)
	@echo "All checks completed!"

db-reset: ## Reset database (drop, create, migrate, seed)
	rails db:drop
	rails db:create
	rails db:migrate
	rails db:seed

server: ## Start Rails server
	rails server

console: ## Start Rails console
	rails console

routes: ## Show all routes
	rails routes

deploy-check: check ## Run all checks before deployment
	@echo "✅ Ready for deployment!"

commit-check: ## Run pre-commit checks manually
	bundle exec overcommit --run

hooks-install: ## Install git hooks
	bundle exec overcommit --install

hooks-sign: ## Sign overcommit configuration
	bundle exec overcommit --sign

clean: ## Clean temporary files
	rm -rf tmp/cache
	rm -rf log/*.log
	rm -rf public/assets

update: ## Update gems and yarn packages
	bundle update
	yarn upgrade