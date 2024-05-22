# Set the directory for local binaries relative to the current directory
LOCAL_BIN=$(CURDIR)/bin

# Define the path environment variable for make operations, including the local bin directory
MAKE_PATH=$(LOCAL_BIN):/bin:/usr/bin:/usr/local/bin

# Define a target to ensure the local binary directory exists
.PHONY: bin-default
bin-default:
	@mkdir -p $(LOCAL_BIN)  # Create the local binary directory if it does not exist

# Define a target to setup a standard .gitignore file by cloning a specific repository
.gitignore:
	@tmpdir=$$(mktemp -d) && \  # Create a temporary directory
	git clone --depth 1 --single-branch https://github.com/partyzanex/go-makefile.git $$tmpdir && \  # Clone the repository into the temporary directory
	cp $$tmpdir/template.gitignore $(CURDIR)/.gitignore  # Copy the .gitignore template from the cloned repo to the current directory

# Define a pattern rule that associates any target with its default version
%:  %-default
	@  true  # This is a fallback pattern that does nothing but allows the rule to succeed, used for extending the makefile cleanly
