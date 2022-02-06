#!/bin/bash

APP="/docker"
MOSQUITTO_ROOT="$APP/mqtt"
MOSQUITTO_CONF="$MOSQUITTO_ROOT/conf"
MOSQUITTO_DATA="$MOSQUITTO_ROOT/data"
MOSQUITTO_LOG="$MOSQUITTO_ROOT/log"

if [ -d "$MOSQUITTO_ROOT" ]
then
	echo "mosquitto data already present"
else
	echo "no mosquitto data, creating folder"
	mkdir -p $MOSQUITTO_ROOT
        mkdir -p $MOSQUITTO_CONF
        mkdir -p $MOSQUITTO_DATA
        mkdir -p $MOSQUITTO_LOG

cat <<EOF > $MOSQUITTO_CONF/mosquitto.conf
# Config file for mosquitto
#
# See mosquitto.conf(5) for more information.
#
# Default values are shown, uncomment to change.
#
# Use the # character to indicate a comment, but only if it is the 
# very first character on the line.

# =================================================================
# General configuration
# =================================================================

# Time in seconds between updates of the $SYS tree.
# Set to 0 to disable the publishing of the $SYS tree.
#sys_interval 10

# Time in seconds between cleaning the internal message store of 
# unreferenced messages. Lower values will result in lower memory 
# usage but more processor time, higher values will have the 
# opposite effect.
# Setting a value of 0 means the unreferenced messages will be 
# disposed of as quickly as possible.
#store_clean_interval 10

# Write process id to a file. Default is a blank string which means 
# a pid file shouldn't be written.
# This should be set to /var/run/mosquitto.pid if mosquitto is
# being run automatically on boot with an init script and 
# start-stop-daemon or similar.
#pid_file

# When run as root, drop privileges to this user and its primary 
# group.
# Set to root to stay as root, but this is not recommended.
# If run as a non-root user, this setting has no effect.
# Note that on Windows this has no effect and so mosquitto should 
# be started by the user you wish it to run as.
#user mosquitto

# The maximum number of QoS 1 and 2 messages currently inflight per 
# client.
# This includes messages that are partway through handshakes and 
# those that are being retried. Defaults to 20. Set to 0 for no 
# maximum. Setting to 1 will guarantee in-order delivery of QoS 1 
# and 2 messages.
#max_inflight_messages 20

# QoS 1 and 2 messages will be allowed inflight per client until this limit
# is exceeded.  Defaults to 0. (No maximum)
# See also max_inflight_messages
#max_inflight_bytes 0

# The maximum number of QoS 1 and 2 messages to hold in a queue per client
# above those that are currently in-flight.  Defaults to 100. Set 
# to 0 for no maximum (not recommended).
# See also queue_qos0_messages.
# See also max_queued_bytes.
#max_queued_messages 100

# QoS 1 and 2 messages above those currently in-flight will be queued per
# client until this limit is exceeded.  Defaults to 0. (No maximum)
# See also max_queued_messages.
# If both max_queued_messages and max_queued_bytes are specified, packets will
# be queued until the first limit is reached.
#max_queued_bytes 0

# Set to true to queue messages with QoS 0 when a persistent client is
# disconnected. These messages are included in the limit imposed by
# max_queued_messages and max_queued_bytes
# Defaults to false.
# This is a non-standard option for the MQTT v3.1 spec but is allowed in
# v3.1.1.
#queue_qos0_messages false

# This option sets the maximum publish payload size that the broker will allow.
# Received messages that exceed this size will not be accepted by the broker.
# The default value is 0, which means that all valid MQTT messages are
# accepted. MQTT imposes a maximum payload size of 268435455 bytes. 
#message_size_limit 0

# This option controls whether a client is allowed to connect with a zero
# length client id or not. This option only affects clients using MQTT v3.1.1
# and later. If set to false, clients connecting with a zero length client id
# are disconnected. If set to true, clients will be allocated a client id by
# the broker. This means it is only useful for clients with clean session set
# to true.
#allow_zero_length_clientid true

# If allow_zero_length_clientid is true, this option allows you to set a prefix
# to automatically generated client ids to aid visibility in logs.
#auto_id_prefix

# This option allows persistent clients (those with clean session set to false)
# to be removed if they do not reconnect within a certain time frame.
#
# This is a non-standard option in MQTT V3.1 but allowed in MQTT v3.1.1.
#
# Badly designed clients may set clean session to false whilst using a randomly
# generated client id. This leads to persistent clients that will never
# reconnect. This option allows these clients to be removed.
#
# The expiration period should be an integer followed by one of h d w m y for
# hour, day, week, month and year respectively. For example
#
# persistent_client_expiration 2m
# persistent_client_expiration 14d
# persistent_client_expiration 1y
#
# The default if not set is to never expire persistent clients.
#persistent_client_expiration

# If a client is subscribed to multiple subscriptions that overlap, e.g. foo/#
# and foo/+/baz , then MQTT expects that when the broker receives a message on
# a topic that matches both subscriptions, such as foo/bar/baz, then the client
# should only receive the message once.
# Mosquitto keeps track of which clients a message has been sent to in order to
# meet this requirement. The allow_duplicate_messages option allows this
# behaviour to be disabled, which may be useful if you have a large number of
# clients subscribed to the same set of topics and are very concerned about
# minimising memory usage.
# It can be safely set to true if you know in advance that your clients will
# never have overlapping subscriptions, otherwise your clients must be able to
# correctly deal with duplicate messages even when then have QoS=2.
#allow_duplicate_messages false

# The MQTT specification requires that the QoS of a message delivered to a
# subscriber is never upgraded to match the QoS of the subscription. Enabling
# this option changes this behaviour. If upgrade_outgoing_qos is set true,
# messages sent to a subscriber will always match the QoS of its subscription.
# This is a non-standard option explicitly disallowed by the spec.
#upgrade_outgoing_qos false

# Disable Nagle's algorithm on client sockets. This has the effect of reducing
# latency of individual messages at the potential cost of increasing the number
# of packets being sent.
#set_tcp_nodelay false

# Use per listener security settings.
# If this option is set to true, then all authentication and access control
# options are controlled on a per listener basis. The following options are
# affected:
#
# password_file acl_file psk_file auth_plugin auth_opt_* allow_anonymous
# auto_id_prefix allow_zero_length_clientid
#
# The default behaviour is for this to be set to false, which maintains the 
# setting behaviour from previous versions of mosquitto.
#per_listener_settings false


# =================================================================
# Default listener
# =================================================================

# IP address/hostname to bind the default listener to. If not
# given, the default listener will not be bound to a specific 
# address and so will be accessible to all network interfaces.
# bind_address ip-address/host name
#bind_address

# Port to use for the default listener.
#port 1883

# The maximum number of client connections to allow. This is 
# a per listener setting.
# Default is -1, which means unlimited connections.
# Note that other process limits mean that unlimited connections 
# are not really possible. Typically the default maximum number of 
# connections possible is around 1024.
#max_connections -1

# Choose the protocol to use when listening.
# This can be either mqtt or websockets.
# Websockets support is currently disabled by default at compile time.
# Certificate based TLS may be used with websockets, except that
# only the cafile, certfile, keyfile and ciphers options are supported.
#protocol mqtt

# When a listener is using the websockets protocol, it is possible to serve
# http data as well. Set http_dir to a directory which contains the files you
# wish to serve. If this option is not specified, then no normal http
# connections will be possible.
#http_dir

# Set use_username_as_clientid to true to replace the clientid that a client
# connected with with its username. This allows authentication to be tied to
# the clientid, which means that it is possible to prevent one client
# disconnecting another by using the same clientid.
# If a client connects with no username it will be disconnected as not
# authorised when this option is set to true.
# Do not use in conjunction with clientid_prefixes.
# See also use_identity_as_username.
#use_username_as_clientid

# -----------------------------------------------------------------
# Certificate based SSL/TLS support
# -----------------------------------------------------------------
# The following options can be used to enable SSL/TLS support for 
# this listener. Note that the recommended port for MQTT over TLS
# is 8883, but this must be set manually.
#
# See also the mosquitto-tls man page.

# At least one of cafile or capath must be defined. They both 
# define methods of accessing the PEM encoded Certificate 
# Authority certificates that have signed your server certificate 
# and that you wish to trust.
# cafile defines the path to a file containing the CA certificates.
# capath defines a directory that will be searched for files
# containing the CA certificates. For capath to work correctly, the
# certificate files must have ".crt" as the file ending and you must run
# "openssl rehash <path to capath>" each time you add/remove a certificate.
#cafile
#capath

# Path to the PEM encoded server certificate.
#certfile

# Path to the PEM encoded keyfile.
#keyfile

# This option defines the version of the TLS protocol to use for this listener.
# The default value allows v1.2, v1.1 and v1.0. The valid values are tlsv1.2
# tlsv1.1 and tlsv1.
#tls_version

# By default a TLS enabled listener will operate in a similar fashion to a
# https enabled web server, in that the server has a certificate signed by a CA
# and the client will verify that it is a trusted certificate. The overall aim
# is encryption of the network traffic. By setting require_certificate to true,
# the client must provide a valid certificate in order for the network
# connection to proceed. This allows access to the broker to be controlled
# outside of the mechanisms provided by MQTT.
#require_certificate false

# If require_certificate is true, you may set use_identity_as_username to true
# to use the CN value from the client certificate as a username. If this is
# true, the password_file option will not be used for this listener.
# This takes priority over use_subject_as_username.
# See also use_subject_as_username.
#use_identity_as_username false

# If require_certificate is true, you may set use_subject_as_username to true
# to use the complete subject value from the client certificate as a username.
# If this is true, the password_file option will not be used for this listener.
# See also use_identity_as_username
#use_subject_as_username false

# If you have require_certificate set to true, you can create a certificate
# revocation list file to revoke access to particular client certificates. If
# you have done this, use crlfile to point to the PEM encoded revocation file.
#crlfile

# If you wish to control which encryption ciphers are used, use the ciphers
# option. The list of available ciphers can be obtained using the "openssl
# ciphers" command and should be provided in the same format as the output of
# that command.
# If unset defaults to DEFAULT:!aNULL:!eNULL:!LOW:!EXPORT:!SSLv2:@STRENGTH
#ciphers DEFAULT:!aNULL:!eNULL:!LOW:!EXPORT:!SSLv2:@STRENGTH

# -----------------------------------------------------------------
# Pre-shared-key based SSL/TLS support
# -----------------------------------------------------------------
# The following options can be used to enable PSK based SSL/TLS support for
# this listener. Note that the recommended port for MQTT over TLS is 8883, but
# this must be set manually.
#
# See also the mosquitto-tls man page and the "Certificate based SSL/TLS
# support" section. Only one of certificate or PSK encryption support can be
# enabled for any listener.

# The psk_hint option enables pre-shared-key support for this listener and also
# acts as an identifier for this listener. The hint is sent to clients and may
# be used locally to aid authentication. The hint is a free form string that
# doesn't have much meaning in itself, so feel free to be creative.
# If this option is provided, see psk_file to define the pre-shared keys to be
# used or create a security plugin to handle them.
#psk_hint

# Set use_identity_as_username to have the psk identity sent by the client used
# as its username. Authentication will be carried out using the PSK rather than
# the MQTT username/password and so password_file will not be used for this
# listener.
#use_identity_as_username false

# When using PSK, the encryption ciphers used will be chosen from the list of
# available PSK ciphers. If you want to control which ciphers are available,
# use the "ciphers" option.  The list of available ciphers can be obtained
# using the "openssl ciphers" command and should be provided in the same format
# as the output of that command.
#ciphers

# =================================================================
# Extra listeners
# =================================================================

# Listen on a port/ip address combination. By using this variable 
# multiple times, mosquitto can listen on more than one port. If 
# this variable is used and neither bind_address nor port given, 
# then the default listener will not be started.
# The port number to listen on must be given. Optionally, an ip 
# address or host name may be supplied as a second argument. In 
# this case, mosquitto will attempt to bind the listener to that 
# address and so restrict access to the associated network and 
# interface. By default, mosquitto will listen on all interfaces.
# Note that for a websockets listener it is not possible to bind to a host
# name.
# listener port-number [ip address/host name]
#listener

# The maximum number of client connections to allow. This is 
# a per listener setting.
# Default is -1, which means unlimited connections.
# Note that other process limits mean that unlimited connections 
# are not really possible. Typically the default maximum number of 
# connections possible is around 1024.
#max_connections -1

# The listener can be restricted to operating within a topic hierarchy using
# the mount_point option. This is achieved be prefixing the mount_point string
# to all topics for any clients connected to this listener. This prefixing only
# happens internally to the broker; the client will not see the prefix.
#mount_point

# Choose the protocol to use when listening.
# This can be either mqtt or websockets.
# Certificate based TLS may be used with websockets, except that only the
# cafile, certfile, keyfile and ciphers options are supported.
#protocol mqtt

# When a listener is using the websockets protocol, it is possible to serve
# http data as well. Set http_dir to a directory which contains the files you
# wish to serve. If this option is not specified, then no normal http
# connections will be possible.
#http_dir

# Set use_username_as_clientid to true to replace the clientid that a client
# connected with with its username. This allows authentication to be tied to
# the clientid, which means that it is possible to prevent one client
# disconnecting another by using the same clientid.
# If a client connects with no username it will be disconnected as not
# authorised when this option is set to true.
# Do not use in conjunction with clientid_prefixes.
# See also use_identity_as_username.
#use_username_as_clientid

# -----------------------------------------------------------------
# Certificate based SSL/TLS support
# -----------------------------------------------------------------
# The following options can be used to enable certificate based SSL/TLS support
# for this listener. Note that the recommended port for MQTT over TLS is 8883,
# but this must be set manually.
#
# See also the mosquitto-tls man page and the "Pre-shared-key based SSL/TLS
# support" section. Only one of certificate or PSK encryption support can be
# enabled for any listener.

# At least one of cafile or capath must be defined to enable certificate based
# TLS encryption. They both define methods of accessing the PEM encoded
# Certificate Authority certificates that have signed your server certificate
# and that you wish to trust.
# cafile defines the path to a file containing the CA certificates.
# capath defines a directory that will be searched for files
# containing the CA certificates. For capath to work correctly, the
# certificate files must have ".crt" as the file ending and you must run
# "openssl rehash <path to capath>" each time you add/remove a certificate.
#cafile
#capath

# Path to the PEM encoded server certificate.
#certfile

# Path to the PEM encoded keyfile.
#keyfile

# By default an TLS enabled listener will operate in a similar fashion to a
# https enabled web server, in that the server has a certificate signed by a CA
# and the client will verify that it is a trusted certificate. The overall aim
# is encryption of the network traffic. By setting require_certificate to true,
# the client must provide a valid certificate in order for the network
# connection to proceed. This allows access to the broker to be controlled
# outside of the mechanisms provided by MQTT.
#require_certificate false

# If require_certificate is true, you may set use_identity_as_username to true
# to use the CN value from the client certificate as a username. If this is
# true, the password_file option will not be used for this listener.
#use_identity_as_username false

# If you have require_certificate set to true, you can create a certificate
# revocation list file to revoke access to particular client certificates. If
# you have done this, use crlfile to point to the PEM encoded revocation file.
#crlfile

# If you wish to control which encryption ciphers are used, use the ciphers
# option. The list of available ciphers can be optained using the "openssl
# ciphers" command and should be provided in the same format as the output of
# that command.
#ciphers

# -----------------------------------------------------------------
# Pre-shared-key based SSL/TLS support
# -----------------------------------------------------------------
# The following options can be used to enable PSK based SSL/TLS support for
# this listener. Note that the recommended port for MQTT over TLS is 8883, but
# this must be set manually.
#
# See also the mosquitto-tls man page and the "Certificate based SSL/TLS
# support" section. Only one of certificate or PSK encryption support can be
# enabled for any listener.

# The psk_hint option enables pre-shared-key support for this listener and also
# acts as an identifier for this listener. The hint is sent to clients and may
# be used locally to aid authentication. The hint is a free form string that
# doesn't have much meaning in itself, so feel free to be creative.
# If this option is provided, see psk_file to define the pre-shared keys to be
# used or create a security plugin to handle them.
#psk_hint

# Set use_identity_as_username to have the psk identity sent by the client used
# as its username. Authentication will be carried out using the PSK rather than
# the MQTT username/password and so password_file will not be used for this
# listener.
#use_identity_as_username false

# When using PSK, the encryption ciphers used will be chosen from the list of
# available PSK ciphers. If you want to control which ciphers are available,
# use the "ciphers" option.  The list of available ciphers can be optained
# using the "openssl ciphers" command and should be provided in the same format
# as the output of that command.
#ciphers

# =================================================================
# Persistence
# =================================================================

# If persistence is enabled, save the in-memory database to disk 
# every autosave_interval seconds. If set to 0, the persistence 
# database will only be written when mosquitto exits. See also
# autosave_on_changes.
# Note that writing of the persistence database can be forced by 
# sending mosquitto a SIGUSR1 signal.
#autosave_interval 1800

# If true, mosquitto will count the number of subscription changes, retained
# messages received and queued messages and if the total exceeds
# autosave_interval then the in-memory database will be saved to disk.
# If false, mosquitto will save the in-memory database to disk by treating
# autosave_interval as a time in seconds.
#autosave_on_changes false

# Save persistent message data to disk (true/false).
# This saves information about all messages, including 
# subscriptions, currently in-flight messages and retained 
# messages.
# retained_persistence is a synonym for this option.
persistence true

# The filename to use for the persistent database, not including 
# the path.
#persistence_file mosquitto.db

# Location for persistent database. Must include trailing /
# Default is an empty string (current directory).
# Set to e.g. /var/lib/mosquitto/ if running as a proper service on Linux or
# similar.
persistence_location /mosquitto/data/

# =================================================================
# Logging
# =================================================================

# Places to log to. Use multiple log_dest lines for multiple 
# logging destinations.
# Possible destinations are: stdout stderr syslog topic file
#
# stdout and stderr log to the console on the named output.
#
# syslog uses the userspace syslog facility which usually ends up 
# in /var/log/messages or similar.
#
# topic logs to the broker topic '$SYS/broker/log/<severity>', 
# where severity is one of D, E, W, N, I, M which are debug, error, 
# warning, notice, information and message. Message type severity is used by
# the subscribe/unsubscribe log_types and publishes log messages to
# $SYS/broker/log/M/susbcribe or $SYS/broker/log/M/unsubscribe.
#
# The file destination requires an additional parameter which is the file to be
# logged to, e.g. "log_dest file /var/log/mosquitto.log". The file will be
# closed and reopened when the broker receives a HUP signal. Only a single file
# destination may be configured.
#
# Note that if the broker is running as a Windows service it will default to
# "log_dest none" and neither stdout nor stderr logging is available.
# Use "log_dest none" if you wish to disable logging.
log_dest file /mosquitto/log/mosquitto.log

# If using syslog logging (not on Windows), messages will be logged to the
# "daemon" facility by default. Use the log_facility option to choose which of
# local0 to local7 to log to instead. The option value should be an integer
# value, e.g. "log_facility 5" to use local5.
#log_facility

# Types of messages to log. Use multiple log_type lines for logging
# multiple types of messages.
# Possible types are: debug, error, warning, notice, information, 
# none, subscribe, unsubscribe, websockets, all.
# Note that debug type messages are for decoding the incoming/outgoing
# network packets. They are not logged in "topics".
#log_type error
#log_type warning
#log_type notice
#log_type information

# Change the websockets logging level. This is a global option, it is not
# possible to set per listener. This is an integer that is interpreted by
# libwebsockets as a bit mask for its lws_log_levels enum. See the
# libwebsockets documentation for more details. "log_type websockets" must also
# be enabled.
#websockets_log_level 0

# If set to true, client connection and disconnection messages will be included
# in the log.
#connection_messages true

# If set to true, add a timestamp value to each log message.
#log_timestamp true

# =================================================================
# Security
# =================================================================

# If set, only clients that have a matching prefix on their 
# clientid will be allowed to connect to the broker. By default, 
# all clients may connect.
# For example, setting "secure-" here would mean a client "secure-
# client" could connect but another with clientid "mqtt" couldn't.
#clientid_prefixes

# Boolean value that determines whether clients that connect 
# without providing a username are allowed to connect. If set to 
# false then a password file should be created (see the 
# password_file option) to control authenticated client access. 
#
# Defaults to true if no other security options are set. If any other
# authentication options are set, then allow_anonymous defaults to false.
#
#allow_anonymous true

# -----------------------------------------------------------------
# Default authentication and topic access control
# -----------------------------------------------------------------

# Control access to the broker using a password file. This file can be
# generated using the mosquitto_passwd utility. If TLS support is not compiled
# into mosquitto (it is recommended that TLS support should be included) then
# plain text passwords are used, in which case the file should be a text file
# with lines in the format:
# username:password
# The password (and colon) may be omitted if desired, although this 
# offers very little in the way of security.
# 
# See the TLS client require_certificate and use_identity_as_username options
# for alternative authentication options. If an auth_plugin is used as well as
# password_file, the auth_plugin check will be made first.
#password_file

# Access may also be controlled using a pre-shared-key file. This requires
# TLS-PSK support and a listener configured to use it. The file should be text
# lines in the format:
# identity:key
# The key should be in hexadecimal format without a leading "0x".
# If an auth_plugin is used as well, the auth_plugin check will be made first.
#psk_file

# Control access to topics on the broker using an access control list
# file. If this parameter is defined then only the topics listed will
# have access.
# If the first character of a line of the ACL file is a # it is treated as a
# comment.
# Topic access is added with lines of the format:
#
# topic [read|write|readwrite] <topic>
# 
# The access type is controlled using "read", "write" or "readwrite". This
# parameter is optional (unless <topic> contains a space character) - if not
# given then the access is read/write.  <topic> can contain the + or #
# wildcards as in subscriptions.
# 
# The first set of topics are applied to anonymous clients, assuming
# allow_anonymous is true. User specific topic ACLs are added after a 
# user line as follows:
#
# user <username>
#
# The username referred to here is the same as in password_file. It is
# not the clientid.
#
#
# If is also possible to define ACLs based on pattern substitution within the
# topic. The patterns available for substition are:
#
# %c to match the client id of the client
# %u to match the username of the client
#
# The substitution pattern must be the only text for that level of hierarchy.
#
# The form is the same as for the topic keyword, but using pattern as the
# keyword.
# Pattern ACLs apply to all users even if the "user" keyword has previously
# been given.
#
# If using bridges with usernames and ACLs, connection messages can be allowed
# with the following pattern:
# pattern write $SYS/broker/connection/%c/state
#
# pattern [read|write|readwrite] <topic>
#
# Example:
#
# pattern write sensor/%u/data
#
# If an auth_plugin is used as well as acl_file, the auth_plugin check will be
# made first.
#acl_file

# -----------------------------------------------------------------
# External authentication and topic access plugin options
# -----------------------------------------------------------------

# External authentication and access control can be supported with the
# auth_plugin option. This is a path to a loadable plugin. See also the
# auth_opt_* options described below. 
#
# The auth_plugin option can be specified multiple times to load multiple
# plugins. The plugins will be processed in the order that they are specified
# here. If the auth_plugin option is specified alongside either of
# password_file or acl_file then the plugin checks will be made first.
#
#auth_plugin

# If the auth_plugin option above is used, define options to pass to the
# plugin here as described by the plugin instructions. All options named
# using the format auth_opt_* will be passed to the plugin, for example:
#
# auth_opt_db_host
# auth_opt_db_port 
# auth_opt_db_username
# auth_opt_db_password


# =================================================================
# Bridges
# =================================================================

# A bridge is a way of connecting multiple MQTT brokers together.
# Create a new bridge using the "connection" option as described below. Set
# options for the bridges using the remaining parameters. You must specify the
# address and at least one topic to subscribe to.
#
# Each connection must have a unique name.
#
# The address line may have multiple host address and ports specified. See
# below in the round_robin description for more details on bridge behaviour if
# multiple addresses are used. Note that if you use an IPv6 address, then you
# are required to specify a port.
#
# The direction that the topic will be shared can be chosen by 
# specifying out, in or both, where the default value is out. 
# The QoS level of the bridged communication can be specified with the next
# topic option. The default QoS level is 0, to change the QoS the topic
# direction must also be given.
#
# The local and remote prefix options allow a topic to be remapped when it is
# bridged to/from the remote broker. This provides the ability to place a topic
# tree in an appropriate location. 
#
# For more details see the mosquitto.conf man page.
#
# Multiple topics can be specified per connection, but be careful 
# not to create any loops.
#
# If you are using bridges with cleansession set to false (the default), then
# you may get unexpected behaviour from incoming topics if you change what
# topics you are subscribing to. This is because the remote broker keeps the
# subscription for the old topic. If you have this problem, connect your bridge
# with cleansession set to true, then reconnect with cleansession set to false
# as normal.
#connection <name>
#address <host>[:<port>] [<host>[:<port>]]
#topic <topic> [[[out | in | both] qos-level] local-prefix remote-prefix]

# Set the version of the MQTT protocol to use with for this bridge. Can be one
# of mqttv311 or mqttv11. Defaults to mqttv311.
#bridge_protocol_version mqttv311

# If a bridge has topics that have "out" direction, the default behaviour is to
# send an unsubscribe request to the remote broker on that topic. This means
# that changing a topic direction from "in" to "out" will not keep receiving
# incoming messages. Sending these unsubscribe requests is not always
# desirable, setting bridge_attempt_unsubscribe to false will disable sending
# the unsubscribe request.
#bridge_attempt_unsubscribe true

# If the bridge has more than one address given in the address/addresses
# configuration, the round_robin option defines the behaviour of the bridge on
# a failure of the bridge connection. If round_robin is false, the default
# value, then the first address is treated as the main bridge connection. If
# the connection fails, the other secondary addresses will be attempted in
# turn. Whilst connected to a secondary bridge, the bridge will periodically
# attempt to reconnect to the main bridge until successful.
# If round_robin is true, then all addresses are treated as equals. If a
# connection fails, the next address will be tried and if successful will
# remain connected until it fails
#round_robin false

# Set the client id to use on the remote end of this bridge connection. If not
# defined, this defaults to 'name.hostname' where name is the connection name
# and hostname is the hostname of this computer.
# This replaces the old "clientid" option to avoid confusion. "clientid"
# remains valid for the time being.
#remote_clientid

# Set the clientid to use on the local broker. If not defined, this defaults to
# 'local.<clientid>'. If you are bridging a broker to itself, it is important
# that local_clientid and clientid do not match.
#local_clientid

# Set the clean session variable for this bridge.
# When set to true, when the bridge disconnects for any reason, all 
# messages and subscriptions will be cleaned up on the remote 
# broker. Note that with cleansession set to true, there may be a 
# significant amount of retained messages sent when the bridge 
# reconnects after losing its connection.
# When set to false, the subscriptions and messages are kept on the 
# remote broker, and delivered when the bridge reconnects.
#cleansession false

# If set to true, publish notification messages to the local and remote brokers
# giving information about the state of the bridge connection. Retained
# messages are published to the topic $SYS/broker/connection/<clientid>/state
# unless the notification_topic option is used.
# If the message is 1 then the connection is active, or 0 if the connection has
# failed.
#notifications true

# Choose the topic on which notification messages for this bridge are
# published. If not set, messages are published on the topic
# $SYS/broker/connection/<clientid>/state
#notification_topic 

# Set the keepalive interval for this bridge connection, in 
# seconds.
#keepalive_interval 60

# Set the start type of the bridge. This controls how the bridge starts and
# can be one of three types: automatic, lazy and once. Note that RSMB provides
# a fourth start type "manual" which isn't currently supported by mosquitto.
#
# "automatic" is the default start type and means that the bridge connection
# will be started automatically when the broker starts and also restarted
# after a short delay (30 seconds) if the connection fails.
#
# Bridges using the "lazy" start type will be started automatically when the
# number of queued messages exceeds the number set with the "threshold"
# parameter. It will be stopped automatically after the time set by the
# "idle_timeout" parameter. Use this start type if you wish the connection to
# only be active when it is needed.
#
# A bridge using the "once" start type will be started automatically when the
# broker starts but will not be restarted if the connection fails.
#start_type automatic

# Set the amount of time a bridge using the automatic start type will wait
# until attempting to reconnect.  Defaults to 30 seconds.
#restart_timeout 30

# Set the amount of time a bridge using the lazy start type must be idle before
# it will be stopped. Defaults to 60 seconds.
#idle_timeout 60

# Set the number of messages that need to be queued for a bridge with lazy
# start type to be restarted. Defaults to 10 messages.
# Must be less than max_queued_messages.
#threshold 10

# If try_private is set to true, the bridge will attempt to indicate to the
# remote broker that it is a bridge not an ordinary client. If successful, this
# means that loop detection will be more effective and that retained messages
# will be propagated correctly. Not all brokers support this feature so it may
# be necessary to set try_private to false if your bridge does not connect
# properly.
#try_private true

# Set the username to use when connecting to a broker that requires
# authentication.
# This replaces the old "username" option to avoid confusion. "username"
# remains valid for the time being.
#remote_username

# Set the password to use when connecting to a broker that requires
# authentication. This option is only used if remote_username is also set.
# This replaces the old "password" option to avoid confusion. "password"
# remains valid for the time being.
#remote_password

# -----------------------------------------------------------------
# Certificate based SSL/TLS support
# -----------------------------------------------------------------
# Either bridge_cafile or bridge_capath must be defined to enable TLS support
# for this bridge.
# bridge_cafile defines the path to a file containing the
# Certificate Authority certificates that have signed the remote broker
# certificate.
# bridge_capath defines a directory that will be searched for files containing
# the CA certificates. For bridge_capath to work correctly, the certificate
# files must have ".crt" as the file ending and you must run "openssl rehash
# <path to capath>" each time you add/remove a certificate.
#bridge_cafile
#bridge_capath

# Path to the PEM encoded client certificate, if required by the remote broker.
#bridge_certfile

# Path to the PEM encoded client private key, if required by the remote broker.
#bridge_keyfile

# When using certificate based encryption, bridge_insecure disables
# verification of the server hostname in the server certificate. This can be
# useful when testing initial server configurations, but makes it possible for
# a malicious third party to impersonate your server through DNS spoofing, for
# example. Use this option in testing only. If you need to resort to using this
# option in a production environment, your setup is at fault and there is no
# point using encryption.
#bridge_insecure false

# -----------------------------------------------------------------
# PSK based SSL/TLS support
# -----------------------------------------------------------------
# Pre-shared-key encryption provides an alternative to certificate based
# encryption. A bridge can be configured to use PSK with the bridge_identity
# and bridge_psk options. These are the client PSK identity, and pre-shared-key
# in hexadecimal format with no "0x". Only one of certificate and PSK based
# encryption can be used on one
# bridge at once.
#bridge_identity
#bridge_psk


# =================================================================
# External config files
# =================================================================

# External configuration files may be included by using the 
# include_dir option. This defines a directory that will be searched
# for config files. All files that end in '.conf' will be loaded as
# a configuration file. It is best to have this as the last option
# in the main file. This option will only be processed from the main
# configuration file. The directory specified must not contain the 
# main configuration file.
#include_dir

# =================================================================
# rsmb options - unlikely to ever be supported
# =================================================================

#ffdc_output
#max_log_entries
#trace_level
#trace_output
EOF

	sudo chown -R 1883:1883 $MOSQUITTO_ROOT
fi

docker stop mqtt
docker rm mqtt

docker run -itd \
	--name=mqtt \
        -p 1883:1883 -p 9001:9001 -v \
	--restart=always \
	-v $MOSQUITTO_CONF:/mosquitto/config \
	-v $MOSQUITTO_DATA:/mosquitto/data \
	-v $MOSQUITTO_LOG:/mosquitto/log \
	eclipse-mosquitto

docker update  --restart=unless-stopped mqtt

docker start mqtt
