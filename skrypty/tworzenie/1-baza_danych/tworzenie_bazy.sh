#!/bin/bash

database=sumlib
user=asia
port=5432
pass=null
host=localhost
current=.

if [ $# -gt 0 ]; then database=$1; shift 1; fi 
if [ $# -gt 0 ]; then host=$1; shift 1; fi 
if [ $# -gt 0 ]; then port=$1; shift 1; fi 
if [ $# -gt 0 ]; then user=$1; shift 1; fi
if [ $# -gt 0 ]; then pass=$1; shift 1; fi 
if [ $# -gt 0 ]; then current=$1; shift 1; fi 
if [ $host = localhost ]; then
    host='';
else
    host="-h = $host"
fi
$current/../common/info "tworzenie user-a $user"
echo "create user $user password '$pass';" | psql $host -p $port 
$current/../common/info "tworzenie bazy $database"
echo "create database $database with owner $user;" | psql $host -p $port 

