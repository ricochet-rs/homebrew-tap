# Homebrew tap testing recipes

# Default recipe - show available commands
default:
    @just --list

# Run brew style checks on the formula (skip file permissions check)
style:
    brew style --except-cops=FormulaAudit/Files ./Formula/ricochet.rb

# Run brew audit on the formula
audit:
    brew audit --strict --online ./Formula/ricochet.rb

# Install the formula locally for testing
install:
    brew install --build-from-source ./Formula/ricochet.rb

# Reinstall the formula
reinstall:
    brew reinstall --build-from-source ./Formula/ricochet.rb

# Uninstall the formula
uninstall:
    brew uninstall ricochet

# Run the formula's test block
test:
    brew test ricochet

# Full local test suite: style, audit, install, and test
test-all: style audit install test
    @echo "✓ All tests passed!"

# Clean up - uninstall and clean build artifacts
clean:
    -brew uninstall ricochet
    brew cleanup ricochet

# Check formula info
info:
    brew info ./Formula/ricochet.rb

# Install in verbose mode for debugging
install-verbose:
    brew install --build-from-source --verbose ./Formula/ricochet.rb

# Dry run of installation
install-dry-run:
    brew install --build-from-source --dry-run ./Formula/ricochet.rb
