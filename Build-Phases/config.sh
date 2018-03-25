function readJson {  
  UNAMESTR=`uname`
  if [[ "$UNAMESTR" == 'Linux' ]]; then
    SED_EXTENDED='-r'
  elif [[ "$UNAMESTR" == 'Darwin' ]]; then
    SED_EXTENDED='-E'
  fi; 

  VALUE=`grep -m 1 "\"${2}\"" ${1} | sed ${SED_EXTENDED} 's/^ *//;s/.*: *"//;s/",?//'`

  if [ ! "$VALUE" ]; then
    echo "Error: Cannot find \"${2}\" in ${1}" >&2;
    exit 1;
  else
    echo $VALUE ;
  fi; 
}

# set -x;
# FABRIC_API_KEY=$(readJson ${SRCROOT}/TCAT/Supporting\ Files/config.json fabric-api)
# FABRIC_BUILD_SECRET=$(readJson ${SRCROOT}/TCAT/Supporting\ Files/config.json fabric-secret)

"${PODS_ROOT}/Fabric/run" $FABRIC_API_KEY $FABRIC_BUILD_SECRET
