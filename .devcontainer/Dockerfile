FROM mcr.microsoft.com/devcontainers/ruby:0-3.1-bullseye

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains 
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# Install Node.js.
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install 18" 2>&1
