#!/bin/bash
echo "terraform-in20hours" > index.html
nohup busybox httpd -f -p 8080 &
