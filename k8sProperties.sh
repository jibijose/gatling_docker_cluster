#################### editable variables ############################
K8S_NAMESPACE=gatlingcluster
DOCKER_HOST=registry.hub.docker.com
DOCKER_USER=jibijose

#################### other variables ############################
LOADPROFILE=loadprofile.scala
K8SPROPERTIES=k8sProperties.sh
K8S_DEPLOY_FILE=k8s.yaml
CONFIGMAP_LOADPROFILE_NAME=loadprofile.scala
CONFIGMAP_K8S_PROPS_NAME=k8s.properties
K8S_DEPLOY_FILE_TEMP=k8s_temp.yaml
DOCKERHUB_NODE_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingnode:latest
DOCKERHUB_JOINER_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingjoiner:latest
DOCKER_GATLING_HOME=/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1
DOCKER_GATLING_COPIED_DIR=${DOCKER_GATLING_HOME}/copied-run-files


NUM_OF_NODES=3
PVC_SIZE=5Gi

NODE_CPU_REQUEST=2Gi
NODE_MEMORY_REQUEST=1000m
NODE_CPU_LIMIT=2Gi
NODE_MEMORY_LIMIT=1000m

JOINER_CPU_REQUEST=2Gi
JOINER_MEMORY_REQUEST=1000m
JOINER_CPU_LIMIT=2Gi
JOINER_MEMORY_LIMIT=1000m



