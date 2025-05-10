# Define the Vagrant box name (optional)
VAGRANT_BOX = avnlearn-box

# Define the Vagrantfile path
VAGRANTFILE = Vagrantfile

# Define the output box file name based on the VAGRANT_BOX variable
OUTPUT_BOX = $(VAGRANT_BOX).box

# Define the Vagrant command
VAGRANT_CMD = vagrant

# Check if Vagrant is installed
VAGRANT_CHECK := $(shell command -v $(VAGRANT_CMD) 2> /dev/null)

# Default target
.PHONY: all
all: up

# Check for Vagrant installation
check-vagrant:
	@if [ -z "$(VAGRANT_CHECK)" ]; then \
		echo "Error: Vagrant is not installed. Please install Vagrant first."; \
		exit 1; \
	fi

# Start the Vagrant box
.PHONY: up
up: check-vagrant
	@$(VAGRANT_CMD) up || { echo "Failed to start the Vagrant box."; exit 1; }

# Halt the Vagrant box
.PHONY: halt
halt: check-vagrant
	@$(VAGRANT_CMD) halt || { echo "Failed to halt the Vagrant box."; exit 1; }

# Destroy the Vagrant box
.PHONY: destroy
destroy: check-vagrant
	@$(VAGRANT_CMD) destroy -f || { echo "Failed to destroy the Vagrant box."; exit 1; }

# Clean the Vagrant box (same as destroy)
.PHONY: clean
clean: destroy

# SSH into the Vagrant box
.PHONY: ssh
ssh: check-vagrant
	@$(VAGRANT_CMD) ssh || { echo "Failed to SSH into the Vagrant box."; exit 1; }

# Reload the Vagrant box
.PHONY: reload
reload: check-vagrant
	@$(VAGRANT_CMD) reload || { echo "Failed to reload the Vagrant box."; exit 1; }

# Provision the Vagrant box
.PHONY: provision
provision: check-vagrant
	@$(VAGRANT_CMD) provision || { echo "Failed to provision the Vagrant box."; exit 1; }

# Show the status of the Vagrant box
.PHONY: status
status: check-vagrant
	@$(VAGRANT_CMD) status || { echo "Failed to get the status of the Vagrant box."; exit 1; }

# Show the IP address of the Vagrant box
.PHONY: ip
ip: check-vagrant
	@$(VAGRANT_CMD) ssh -c "hostname -I" || { echo "Failed to get the IP address of the Vagrant box."; exit 1; }

# Package the Vagrant box
.PHONY: package
package: check-vagrant
	@$(VAGRANT_CMD) package --output $(OUTPUT_BOX) || { echo "Failed to package the Vagrant box."; exit 1; }

# Add the Vagrant box
.PHONY: add
add:
	@$(VAGRANT_CMD) box add $(VAGRANT_BOX) $(OUTPUT_BOX) || { echo "Failed to add the Vagrant box."; exit 1; }

# List all available Vagrant commands
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make up         - Start the Vagrant box"
	@echo "  make halt       - Halt the Vagrant box"
	@echo "  make destroy     - Destroy the Vagrant box"
	@echo "  make clean      - Clean (destroy) the Vagrant box"
	@echo "  make ssh        - SSH into the Vagrant box"
	@echo "  make reload     - Reload the Vagrant box"
	@echo "  make provision   - Provision the Vagrant box"
	@echo "  make status     - Show the status of the Vagrant box"
	@echo "  make ip        - Show the IP address of the Vagrant box"
	@echo "  make package     - Package the Vagrant box into a .box file"
	@echo "  make add        - Add the Vagrant box to Vagrant"
	@echo "  make help       - Show this help message"
