#################### editable variables ############################
LOAD_PROFILE_NAME=loadprofile
K8S_NAMESPACE=gatlingcluster

PVC_SIZE=5Gi

NUM_OF_NODES=3
NODE_CPU_REQUEST=500m
NODE_MEMORY_REQUEST=1Gi
NODE_CPU_LIMIT=1000m
NODE_MEMORY_LIMIT=2Gi

JOINER_CPU_REQUEST=1000m
JOINER_MEMORY_REQUEST=4Gi
JOINER_CPU_LIMIT=2000m
JOINER_MEMORY_LIMIT=10Gi

GATLING_REQ_LOWER_BOUND=100
GATLING_REQ_HIGHER_BOUND=250
GATLING_ENABLE_GA=false
GATLING_MAX_RETRY=3
GATLING_REQ_TIMEOUT=500

BUILD_TIME_INTERVAL=10
RUN_TIME_INTERVAL=10
#################### other variables ############################
DOCKER_HOST=registry.hub.docker.com
DOCKER_USER=jibijose
LOAD_PROFILE_SCALA=${LOAD_PROFILE_NAME}.scala
LOAD_PROFILE_JSON=${LOAD_PROFILE_NAME}.json
K8SPROPERTIES=k8sProperties.sh
K8S_DEPLOY_FILE=k8s.yaml
CONFIGMAP_LOAD_PROFILE=${LOAD_PROFILE_NAME}
K8S_DEPLOY_FILE_TEMP=k8s_temp.yaml
DOCKERHUB_NODE_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingnode:latest
DOCKERHUB_JOINER_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingjoiner:latest

GATLING_HOME=/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1
GATLING_SIMULATIONS_DIR=${GATLING_HOME}/user-files/simulations
GATLING_RESULTS_DIR=${GATLING_HOME}/results
GATLING_COPIED_DIR=${GATLING_HOME}/copied-run-files
GATLING_RUNNER=${GATLING_HOME}/bin/gatling.sh
GATLING_CONF=${GATLING_HOME}/conf/gatling.conf
GATLING_RESOURCES_DIR=${GATLING_HOME}/user-files/resources

PVC_DATA=/pvc-data

function setGatlingMemory() {
    NODE_MAX_MEMORY_GB=$(echo $NODE_MEMORY_LIMIT | sed 's/[^0-9]*//g')
    JOINER_MAX_MEMORY_GB=$(echo $JOINER_MEMORY_LIMIT | sed 's/[^0-9]*//g')

    echo "Setting node and joiner gatling memories as 75% of max available memory"
    GATLING_NODE_MAX_MEMORY=$( expr 1024 '*' "$NODE_MAX_MEMORY_GB" '*' 3 '/' 4 )
    GATLING_JOINER_MAX_MEMORY=$( expr 1024 '*' "$JOINER_MAX_MEMORY_GB" '*' 3 '/' 4 )
    GATLING_NODE_MAX_MEMORY=${GATLING_NODE_MAX_MEMORY}M
    echo "Gatling node maximum memory is $GATLING_NODE_MAX_MEMORY MB"
    GATLING_JOINER_MAX_MEMORY=${GATLING_JOINER_MAX_MEMORY}M
    echo "Gatling joiner maximum memory is $GATLING_JOINER_MAX_MEMORY MB"
}
setGatlingMemory


