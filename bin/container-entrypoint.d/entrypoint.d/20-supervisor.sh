#!/usr/bin/env bash

SUPERVISOR_XMLRPC_UNIX_SOCKET_PATH_DEFAULT="/app/var/run/supervisor.sock"
SUPERVISOR_XMLRPC_UNIX_SOCKET_CHMOD_DEFAULT="0700"
SUPERVISOR_XMLRPC_UNIX_SOCKET_CHOWN_DEFAULT="1001:0"

SUPERVISOR_XMLRPC_INET_HOST_DEFAULT=""
SUPERVISOR_XMLRPC_INET_PORT_DEFAULT="9744"
SUPERVISOR_XMLRPC_INET_USERNAME_DEFAULT="admin"
SUPERVISOR_XMLRPC_INET_PASSWORD_DEFAULT="pa55w0rd"

export SUPERVISOR_XMLRPC_UNIX_SOCKET_PATH=${SUPERVISOR_XMLRPC_UNIX_SOCKET_PATH:-"${SUPERVISOR_XMLRPC_UNIX_SOCKET_PATH_DEFAULT}"}
export SUPERVISOR_XMLRPC_UNIX_SOCKET_CHMOD=${SUPERVISOR_XMLRPC_UNIX_SOCKET_CHMOD:-"${SUPERVISOR_XMLRPC_UNIX_SOCKET_CHMOD_DEFAULT}"}
export SUPERVISOR_XMLRPC_UNIX_SOCKET_CHOWN=${SUPERVISOR_XMLRPC_UNIX_SOCKET_CHOWN:-"${SUPERVISOR_XMLRPC_UNIX_SOCKET_CHOWN_DEFAULT}"}

export SUPERVISOR_XMLRPC_INET_HOST=${SUPERVISOR_XMLRPC_INET_HOST:-"${SUPERVISOR_XMLRPC_INET_HOST_DEFAULT}"}
export SUPERVISOR_XMLRPC_INET_PORT=${SUPERVISOR_XMLRPC_INET_PORT:-"${SUPERVISOR_XMLRPC_INET_PORT_DEFAULT}"}
export SUPERVISOR_XMLRPC_INET_USERNAME=${SUPERVISOR_XMLRPC_INET_USERNAME:-"${SUPERVISOR_XMLRPC_INET_USERNAME_DEFAULT}"}
export SUPERVISOR_XMLRPC_INET_PASSWORD=${SUPERVISOR_XMLRPC_INET_PASSWORD:-"${SUPERVISOR_XMLRPC_INET_PASSWORD_DEFAULT}"}

true
