#!/bin/sh

export JAVA_OPTS="$JAVA_OPTS "
#echo JAVA_OPTS="$JAVA_OPTS"
#export NEW_RELIC_OPTS=" -Dnewrelic.config.license_key=$NEW_RELIC_CONFIG_LICENSE_KEY -Dnewrelic.config.app_name=$NEW_RELIC_CONFIG_APP_NAME -Dnewrelic.config.process_host.display_name=$NEW_RELIC_DISPLAY_NAME "
export NEW_RELIC_OPTS="-javaagent:/opt/newrelic/newrelic.jar -Dnewrelic.config.license_key=$NEW_RELIC_CONFIG_LICENSE_KEY -Dnewrelic.config.app_name=$NEW_RELIC_CONFIG_APP_NAME -Dnewrelic.config.process_host.display_name=$NEW_RELIC_DISPLAY_NAME "
#echo NEW_RELIC_OPTS="$NEW_RELIC_OPTS"
export CLASSPATH="-cp /var/runtime/lib/*:/var/task/lib/*:/var/task/"
#echo CLASSPATH="$CLASSPATH"
#echo "$JAVA_OPTS" "$NEW_RELIC_OPTS" "$CLASSPATH --add-opens java.base/java.util=ALL-UNNAMED " "$MAIN_CLASS" "$LAMBDA_HANDLER"

/usr/bin/java $JAVA_OPTS $NEW_RELIC_OPTS $CLASSPATH --add-opens java.base/java.util=ALL-UNNAMED $MAIN_CLASS $LAMBDA_HANDLER


