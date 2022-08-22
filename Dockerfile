FROM ubuntu:latest

# install dependencies
RUN apt-get update
RUN apt-get install -y build-essential git curl sudo language-pack-en

# create user
RUN useradd -ms /bin/bash user && \
        echo "user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
        chmod 0440 /etc/sudoers.d/user

USER user:user

WORKDIR /home/user

RUN git clone https://github.com/rbakkkam/dotfiles $HOME/src/dotfiles
