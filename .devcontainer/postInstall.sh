#!/bin/sh


# Install Zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# Update .zshrc to load the new plugins
sed -i 's/^plugins=(git)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

MAVEN_VERSION=3.9.9

wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
tar -xvf apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo mv apache-maven-${MAVEN_VERSION} /opt/

sed -i "\$ a\M2_HOME=\"/opt/apache-maven-${MAVEN_VERSION}\"" ~/.zshrc
sed -i '$ a\PATH="\$M2_HOME/bin:\$PATH"' ~/.zshrc
rm apache-maven-${MAVEN_VERSION}-bin.tar.gz*

./create-env.sh