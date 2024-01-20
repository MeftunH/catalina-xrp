function HELP() {
  echo "Usage: $0 -b /path/to/cataline_base"
  echo "Usage: $0 -c /path/to/cataline_home"
  echo "Usage: $0 -n app_name"
}

while getopts b:c:n:h FLAG; do
  case $FLAG in
    b)
      CATALINA_BASE=$OPTARG
      ;;
    c)
      CATALINA_HOME=$OPTARG
      ;;
    n)
      APP_NAME=$OPTARG
      ;;
    h)
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -$OPTARG not allowed."
      HELP
      ;;
  esac
done

if [ "${CATALINA_HOME}" == "" ]; then
  echo "-c CATALINA_HOME is not defined."
  HELP
  exit 1
fi

if [ "${CATALINA_BASE}" == "" ]; then
  echo "-b CATALINA_BASE is not defined."
  HELP
  exit 1
fi

if [ "${APP_NAME}" == "" ]; then
  echo "-n APP_NAME is not defined."
  HELP
  exit 1
fi

echo "Name: ${APP_NAME}"
echo "CATALINA_HOME: ${CATALINA_HOME}"
echo "CATALINA_BASE: ${CATALINA_BASE}"
APP_BASE=${CATALINA_BASE}/${APP_NAME}
APP_CATALINA_BASE=${APP_BASE}/catalina_base

#
# Check the target base directory exists
#
if [ -d "${APP_CATALINA_BASE}" ]; then
  rm -rf "${APP_CATALINA_BASE}"
  echo "Cleaned ${APP_CATALINA_BASE}"
fi

mkdir -p "${APP_CATALINA_BASE}"

if [ ! -d ${APP_CATALINA_BASE} ]; then
  echo "Error: APP_CATALINA_BASE does not exists."
  exit 1
fi

echo "Create catalina base sub directories."
mkdir -p ${APP_CATALINA_BASE}
mkdir -p ${APP_CATALINA_BASE}/conf
mkdir -p ${APP_CATALINA_BASE}/logs
mkdir -p ${APP_CATALINA_BASE}/webapps
mkdir -p ${APP_CATALINA_BASE}/temp
mkdir -p ${APP_CATALINA_BASE}/work

echo "Copy server config files."
cp ${CATALINA_HOME}/conf/server.xml ${APP_CATALINA_BASE}/conf
cp ${CATALINA_HOME}/conf/web.xml ${APP_CATALINA_BASE}/conf

echo "Create start.sh."
cp ./templates/start.sh ${APP_BASE}

echo "Create halt.sh."
cp ./templates/halt.sh ${APP_BASE}

echo "Create restart.sh."
cp ./templates/restart.sh ${APP_BASE}

echo "Create logtc."
cp ./templates/logtc ${APP_BASE}

echo "Create app.env file."
cat <<EOT > ${APP_BASE}/app.env
### app name
export APP_NAME=${APP_NAME}

### tomcat install dir
export CATALINA_HOME=${CATALINA_HOME}

### web app instance base dir
export CATALINA_BASE=${APP_CATALINA_BASE}
EOT