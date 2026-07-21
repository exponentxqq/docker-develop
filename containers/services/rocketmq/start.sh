#!/bin/bash
set -euo pipefail

ROLE="${1:-}"

JVM_COMMON=(
  -server
  -XX:-AlwaysPreTouch
  -XX:-UseBiasedLocking
  -XX:+UseG1GC
  -XX:MaxGCPauseMillis=100
  -XX:MaxMetaspaceSize=128m
  -XX:MaxDirectMemorySize=128m
  -XX:ReservedCodeCacheSize=64m
  -Drocketmq.home.dir=/home/rocketmq/rocketmq-4.7.1
)

CP="/home/rocketmq/rocketmq-4.7.1/lib/*:/home/rocketmq/rocketmq-4.7.1/conf"

case "$ROLE" in
namesrv)
  exec java "${JVM_COMMON[@]}" -Xms256m -Xmx256m -cp "$CP" \
    org.apache.rocketmq.namesrv.NamesrvStartup
  ;;
broker)
  BROKER_CONF=/tmp/broker.conf
  sed "s|\${HOME}|${HOME}|g" /etc/rocketmq/broker.conf > "$BROKER_CONF"
  exec java "${JVM_COMMON[@]}" -Xms256m -Xmx384m -cp "$CP" \
    org.apache.rocketmq.broker.BrokerStartup -c "$BROKER_CONF"
  ;;
*)
  echo "usage: start.sh namesrv|broker" >&2
  exit 1
  ;;
esac
