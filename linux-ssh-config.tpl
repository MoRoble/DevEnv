cat << EOF >> ~/.ssh/config

host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
EOF