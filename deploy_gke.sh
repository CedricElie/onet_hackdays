#!/bin/bash

#Connect and deploy GKE
# --- Configuration ---
# Replace with your actual Google Cloud Project ID
PROJECT_ID="prj-dil-hackdays-sbx-6ce1" 
PROJECT_REGION="europe-west9"
PROJECT_ZONE="europe-west9-a"
PROJECT_VPC="onet-vpc-$PROJECT_ID"
GKE_CLUSTER="onet-gke-$PROJECT_ID-std"

# --- Functions ---

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Function to authenticate with gcloud
authenticate_gcloud() {
    echo "--- Authenticating with gcloud ---"
    if command_exists gcloud; then
        echo "Attempting to log in. A browser window may open for authentication."
        gcloud auth login --no-launch-browser # Use --no-launch-browser if you're on a headless server and want to copy-paste the URL
        if [ $? -eq 0 ]; then
            echo "gcloud authentication successful."
            return 0
        else
            echo "gcloud authentication failed. Please check your credentials."
            return 1
        fi
    else
        echo "Error: gcloud CLI is not installed. Please install it first."
        echo "Visit: https://cloud.google.com/sdk/docs/install"
        return 1
    fi
}

# Function to set the active gcloud project
set_gcloud_project() {
    echo "--- Setting gcloud project to: $PROJECT_ID ---"
    gcloud config set project "$PROJECT_ID"
    if [ $? -eq 0 ]; then
        echo "Project set successfully."
        return 0
    else
        echo "Failed to set project. Ensure the project ID is correct and you have permissions."
        return 1
    fi
}

# Function to display current gcloud configuration
display_gcloud_config() {
    echo "--- Current gcloud Configuration ---"
    gcloud config list
}

create_vpc() {
    echo "Creating project VPC: $PROJECT_VPC"
    gcloud compute networks create "$PROJECT_VPC" \
    --project=$PROJECT_ID \
    --description="Automatic vpc for gke cluster $GKE_CLUSTER" \
    --subnet-mode=auto \
    --mtu=1460 \
    --bgp-routing-mode=regional \
    --bgp-best-path-selection-mode=legacy

    if [ $? -eq 0 ]; then 
        echo "$PROJECT_VPC Created successfully "
    else
        echo "Failed to Create VPC"
    fi

    echo "Enabling firewall rules"
    gcloud compute firewall-rules create $PROJECT_VPC --network onet-vpc-prj-dil-hackdays-sbx-6ce1 --allow tcp,udp,icmp 

}
# Function to perform example gcloud operations
create_gke() {
    echo "--- Enabling APIs ---"
    gcloud services enable container.googleapis.com
    gcloud services enable compute.googleapis.com
    gcloud services enable artifactregistry.googleapis.com
    gcloud services enable containerregistry.googleapis.com

    if [ $? -eq 0 ]; then 
        echo "API enabled successfully"
    else
        echo "Failed to enable APIs"
    fi

    # Setting gcloud env variables
    gcloud config set project $PROJECT_ID
    gcloud config set compute/region $PROJECT_REGION
    gcloud config set compute/zone $PROJECT_ZONE


    # Creating an autopilot cluster 
    #gcloud container clusters create-auto OneT-GKE-$PROJECT_ID-auto --region=$PROJECT_REGION 

    #Create a standard cluster
    echo "Cluster to be created : $GKE_CLUSTER"
    gcloud container clusters create $GKE_CLUSTER \
    --region=$PROJECT_REGION \
    --machine-type=e2-medium \
    #--network=$PROJECT_VPC \
    --enable-autoscaling --min-nodes=3 --max-nodes=10 \
    --enable-ip-alias \
    --num-nodes=2 \
    --release-channel=regular

    if [ $? -eq 0 ]; then -n
        echo "Cluster $GKE_CLUSTER "
    else
        echo "Failed to create cluster $GKE_CLUSTER"
    fi

    # Get the cluster's credentials
    gcloud container clusters get-credentials $GKE_CLUSTER --zone=$PROJECT_ZONE

    # Verify the cluster
    kubectl get nodes
}


# --- Main Script Execution ---

echo "Starting Google Cloud CLI interaction script."

# Check for gcloud installation
if ! command_exists gcloud; then
    echo "Error: gcloud CLI is not installed. Please install it first."
    echo "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Authenticate
authenticate_gcloud
if [ $? -ne 0 ]; then
    echo "Script exiting due to authentication failure."
    exit 1
fi

# Set Project
set_gcloud_project
if [ $? -ne 0 ]; then
    echo "Script exiting due to project setting failure."
    exit 1
fi

# Display current configuration
display_gcloud_config

# Create a VPC
create_vpc

# Perform example operations
create_gke

echo "Script finished."
