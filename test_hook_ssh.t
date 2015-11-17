#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*


@test "nova launch image: generate and add keys" {
    echo -e 'y' | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''

}


@test "swupd: ssh authorized" {
    expect run_password.expect 
}
