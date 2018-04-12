#!/bin/bash
#-------------------------------------------------------------------------------
# Sync .jar files to nexus repository from current directory
#-------------------------------------------------------------------------------

shopt -s nullglob

while [[ $# -gt 0 ]]
do

key="$1"
case $key in
    -h|--help)
    HELP=YES
    ;;
    -u|--url)
    URL=$2
    shift # past argument
    ;;
    -v|--version)
    FORCE_VERSION=$2
    shift # past argument
    ;;
    --group_id)
    FORCE_GROUP_ID=$2
    shift # past argument
    ;;
    --artifact_id)
    FORCE_ARTIFACT_ID=$2
    shift # past argument
    ;;
esac
shift # past argument or value
done

function show_help {
    echo "-------------------------"
    echo "sync_nexus.sh helper script"
    echo "-------------------------"

    echo "Supported parameters are:"
    echo "-h|--help             Print this help"
    echo "-u|--url [u]          Nexus URL, MANDATORY"
    echo "-v|--version [x]      Force version of jar files to [x]"
    echo "--group_id [x]        Force group id of all jar files to [x]"
    echo "--artifact_id [x]     Force artifact id of all jar files to [x]"
    echo ""
}

if [ -n "$HELP" ]; then
    show_help
    exit
fi

function install_package {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
    if [ "" == "$PKG_OK" ]; then
        echo "--- Installing $1"
        sudo apt-get -qq install -y $1
    fi
}

# Maven is required for syncing
install_package maven

if [ -z "$URL" ]; then
    echo "Give Nexus url to sync files to with param -u|--url. See --help for more information."
    echo "Exiting.."
    exit
fi

for jarFile in *.jar; do
    BASE_NAME="${jarFile/.jar/}"

    VERSION=$(echo "$BASE_NAME" | awk -F"_" '{ print $2 }')
    if [ -n "$FORCE_VERSION" ]; then
        VERSION=$FORCE_VERSION
    fi

    if [ -z "$VERSION" ]; then
        echo "Could not resolve version number for $jarFile, skipping.."
        continue
    fi

    ARTIFACT_ID=$(echo "$BASE_NAME" | awk -F"_" '{ print $1 }' | awk -F"." '{ print $NF }')
    if [ -n "$FORCE_ARTIFACT_ID" ]; then
        ARTIFACT_ID=$FORCE_ARTIFACT_ID
    fi

    if [ -z "$ARTIFACT_ID" ]; then
        echo "Could not resolve artifactId for $jarFile, skipping.."
        continue
    fi

    BASE_GROUP_ID=$(echo "$BASE_NAME" | awk -F"_" ' { print $1 }')
    GROUP_ID="${BASE_GROUP_ID/\.$ARTIFACT_ID/}"
    if [ -n "$FORCE_GROUP_ID" ]; then
        GROUP_ID=$FORCE_GROUP_ID
    fi

    if [ -z "$GROUP_ID" ] || [[ "$GROUP_ID" == "$ARTIFACT_ID" ]]; then
        echo "Could not resolve group id for $jarFile, skipping.."
        continue
    fi

    echo "Syncing $jarFile: VERSION: $VERSION, ARTIFACT_ID: $ARTIFACT_ID, GROUP_ID: $GROUP_ID"
    mvn deploy:deploy-file \
        -DgroupId=$GROUP_ID \
        -DartifactId=$ARTIFACT_ID \
        -Dversion=$VERSION \
        -DgeneratePom=true \
        -Dpackaging=jar \
        -DrepositoryId=nexus \
        -Durl=$URL \
        -Dfile=$jarFile
done
