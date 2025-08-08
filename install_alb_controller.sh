#!/bin/bash
#
# Script to install the AWS Load Balancer Controller
#
# Prerequisites:
# - An existing EKS cluster
# - `aws-cli`, `kubectl`, `helm`, and `eksctl` installed and configured
# - OIDC provider already associated with your EKS cluster

# --- Configuration ---
# !!! IMPORTANT: Set these variables before running the script !!!
CLUSTER_NAME="test"
AWS_REGION="us-east-1"
# ---------------------

# Automatically fetch AWS Account ID
AWS_ACCOUNT_ID=427942813953

# --- Script starts here ---
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Starting AWS Load Balancer Controller setup for cluster: $CLUSTER_NAME in region: $AWS_REGION ---"

# Step 1: Create the IAM Policy
echo "✅ Step 1: Creating IAM policy 'AWSLoadBalancerControllerIAMPolicy'..."
POLICY_DOCUMENT_URL="https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"

# Download the policy document
curl -s -o iam_policy.json $POLICY_DOCUMENT_URL

# Check if the policy already exists
if aws iam get-policy --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME > /dev/null 2>&1; then
    echo "IAM policy '$POLICY_NAME' already exists. Skipping creation."
else
    # Create the IAM policy
    aws iam create-policy \
        --policy-name $POLICY_NAME \
        --policy-document file://iam_policy.json
    echo "IAM policy '$POLICY_NAME' created successfully."
fi

# Clean up the downloaded file
# rm iam_policy.json

# Step 2: Create the IAM Role and Service Account using eksctl
echo "✅ Step 2: Creating IAM Role and Service Account via eksctl..."
# This command uses eksctl to create an IAM role, a Kubernetes service account in the kube-system namespace,
# and associates them using IAM Roles for Service Accounts (IRSA).
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME \
  --region=$AWS_REGION \
  --override-existing-serviceaccounts \
  --approve

echo "IAM Role and Service Account 'aws-load-balancer-controller' created and associated."


echo "✅ Step 3: Associating IAM OIDC provider..."
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=test

echo "✅ Step 4: Installing the AWS Load Balancer Controller via Helm..."
# Add the EKS chart repository
helm repo add eks https://aws.github.io/eks-charts

# Update your local repo to make sure you have the latest charts
helm repo update eks

# Install the Helm chart
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

echo "Helm chart installed successfully."

# Step 4: Verify the installation
echo "✅ Step 5: Verifying the controller deployment..."
# Wait for a moment to allow pods to be created
sleep 15
kubectl get deployment -n kube-system aws-load-balancer-controller

echo "--- 🧑‍💻 AWS Load Balancer Controller installation script finished ---"
echo "You can now create Ingress or Service objects with the required annotations."