#! /bin/bash

checkOpenAMParameters() {
  if [ -z "$OPENAM_HOST" ]; then
    export OPENAM_HOST="openam.example.com"
    echo "OPENAM_HOST not set: using default ${OPENAM_HOST}"
  fi

  if [ -z "$OPENAM_DEPLOYMENT_URI" ]; then
    export OPENAM_DEPLOYMENT_URI="openam"
    echo "OPENAM_DEPLOYMENT_URI not set: using default ${OPENAM_DEPLOYMENT_URI}"
  fi

  if [ -z "$OPENAM_ADMIN_PASSWORD" ]; then
    export OPENAM_ADMIN_PASSWORD="Admin001"
    echo "OPENAM_ADMIN_PASSWORD not set: using default ${OPENAM_ADMIN_PASSWORD}"
  fi

  if [ -z "$OPENAM_VERSION" ]; then
    export OPENAM_VERSION="11.0.3"
    echo "OPENAM_VERSION not set: using default ${OPENAM_VERSION}"
  fi

  if [ $OPENAM_HTTPS = true ]; then
    export SERVER_URL=https://${OPENAM_HOST}:${TOMCAT_HTTPS_PORT}
  else
    export SERVER_URL=http://${OPENAM_HOST}:${TOMCAT_HTTP_PORT}
  fi
}

waitForOpenAM() {
  OPENAM_TEST_URL_PRE_CONFIGURE=${SERVER_URL}/${OPENAM_DEPLOYMENT_URI}/config/options.htm
  until [ "`curl -k -s ${OPENAM_TEST_URL_PRE_CONFIGURE} | grep 'Configuration'`" != "" ];
  do
    echo "INFO: Deploying OpenAM war ...\n"
    sleep 5
  done
  printf "INFO: OpenAM deployed.\n"
}

generateOpenAMConfigurationFile() {
cat <<EOT > /tmp/openam-configuration.txt
SERVER_URL=${SERVER_URL}
DEPLOYMENT_URI=/${OPENAM_DEPLOYMENT_URI}
BASE_DIR=${HOME}/openam
locale=en_US
PLATFORM_LOCALE=en_US
AM_ENC_KEY=
ADMIN_PWD=${OPENAM_ADMIN_PASSWORD}
AMLDAPUSERPASSWD=${OPENAM_ADMIN_PASSWORD}_agent
COOKIE_DOMAIN=
ACCEPT_LICENSES=true
DATA_STORE=embedded
DIRECTORY_SSL=SIMPLE
DIRECTORY_SERVER=${OPENAM_HOST}
DIRECTORY_PORT=50389
DIRECTORY_ADMIN_PORT=4444
DIRECTORY_JMX_PORT=1689
ROOT_SUFFIX=dc=openam,dc=forgerock,dc=org
DS_DIRMGRDN=cn=Directory Manager
DS_DIRMGRPASSWD=${OPENAM_ADMIN_PASSWORD}
EOT
}

checkOpenAMParameters

# Dirty
# Add host mapping for configuration stage
cp /etc/hosts /tmp/hosts
echo "127.0.0.1 ${OPENAM_HOST}" >> /etc/hosts

${CATALINA_HOME}/bin/startup.sh
waitForOpenAM

generateOpenAMConfigurationFile
java -Djavax.net.ssl.trustStore=/tmp/cacerts.jks -Djavax.net.ssl.trustStorePassword=password -jar /tmp/openam-configurator-tool-${OPENAM_VERSION}.jar -f /tmp/openam-configuration.txt

catalina.sh stop

# Restore hosts file
cp /tmp/hosts /etc/hosts && rm /tmp/hosts
