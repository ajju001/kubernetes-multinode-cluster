#!/bin/bash

ssh-keygen -f "${HOME}/.ssh/known_hosts" -R [localhost]:2222
scp -P 2222 vagrant@localhost:.kube/config ~/.kube/