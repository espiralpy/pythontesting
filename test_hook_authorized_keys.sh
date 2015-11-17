#!/bin/bash
cat ~/.ssh/id_rsa.pub | ssh swupd@10.219.106.192 'cat >> ~/.ssh/authorized_keys'


