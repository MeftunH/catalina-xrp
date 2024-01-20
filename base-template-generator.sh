function usage() {
  echo "Usage: $0 -w <workspace> -n <app_name> -g <maven group ID> -b <tomcat base dir>"
  echo "(e.g., $0 -w ~/ws/local -n busyapp -g com.djd.fun"
}

while getopts b:w:n:g:h FLAG; do
  case $FLAG in
    b)
      APP_CATALINA_BASE=$OPTARG
      ;;
    w)
      WORKSPACE=$OPTARG
      ;;
    n)
      APP_NAME=$OPTARG
      ;;
    g)
      GROUP_ID=$OPTARG
      ;;
    h)
      usage
      ;;
    \?)
      echo -e \\n"Option -$OPTARG not allowed."
      usage
      ;;
  esac
done

if [ "${WORKSPACE}" == "" ]; then
  echo "-w WORKSPACE is not defined."
  usage
  exit 1
fi

if [ "${APP_NAME}" == "" ]; then
  echo "-n APP_NAME is not defined."
  usage
  exit 1
fi

if [ "${GROUP_ID}" == "" ]; then
  echo "-n GROUP_ID is not defined."
  usage
  exit 1
fi

if [ "${APP_CATALINA_BASE}" == "" ]; then
  echo "-b APP_CATALINA_BASE is not defined."
  usage
  exit 1
fi

APP_WORKSPACE=${WORKSPACE}/${APP_NAME}
SCRIPT_DIR=${APP_WORKSPACE}/scripts
mkdir -p ${SCRIPT_DIR}

cat <<EOT > ${SCRIPT_DIR}/app.env
### app name
export APP_NAME=${APP_NAME}

### web app instance base dir
export CATALINA_BASE=${APP_CATALINA_BASE}
EOT

echo "Create build.sh."
cp ./templates/build.sh ${SCRIPT_DIR}

echo "Create deploy.sh."
cp ./templates/deploy.sh ${SCRIPT_DIR}

echo "Create maven strucutre."
mkdir -p ${APP_WORKSPACE}/src/main/java
mkdir -p ${APP_WORKSPACE}/src/main/resources
mkdir -p ${APP_WORKSPACE}/src/test/java
mkdir -p ${APP_WORKSPACE}/src/test/resources

sed -e "s/\${GROUP_ID}/${GROUP_ID}/" \
    -e "s/\${ARTIFACT_ID}/${APP_NAME}/" \
    -e "s/\${APP_NAME}/${APP_NAME}/" \
    ./templates/maven/pom.xml > ${APP_WORKSPACE}/pom.xml

mkdir -p ${APP_WORKSPACE}/src/main/webapp/WEB-INF
cp ./templates/web.xml ${APP_WORKSPACE}/src/main/webapp/WEB-INF