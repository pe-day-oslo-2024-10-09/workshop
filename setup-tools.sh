#!/bin/bash

mkdir -p $HOME/.local/bin

echo "Downloading and installing humctl"
curl -fL https://github.com/humanitec/cli/releases/download/v0.30.2/cli_0.30.2_linux_amd64.tar.gz | tar -zx -C $HOME/.local/bin humctl

echo "Downloading and installing the Humanitec Setup Wizard"
curl -fL https://github.com/humanitec-architecture/setup-wizard/releases/download/v0.9.0/setup-wizard_0.9.0_linux_amd64.tar.gz | tar -zx -C $HOME/.local/bin humanitec-setup-wizard

echo "Downloading and installing yq"
curl -fL https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64 -o $HOME/.local/bin/yq && chmod a+x $HOME/.local/bin/yq
