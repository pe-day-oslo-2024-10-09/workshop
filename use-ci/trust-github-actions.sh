#!/bin/bash

if [ "$#" -ne 1 ]
then
  echo "USAGE:"
  echo "sh trust-github-actions.sh <GithubHandle>"
  exit 1
fi

echo "Checking to see if GitHub OIDC Provider is registered"
NUM_PROVIDERS="$(aws iam list-open-id-connect-providers | jq '[.OpenIDConnectProviderList[] | select(.Arn | contains("token.actions.githubusercontent.com"))] | length')"
if [ "$NUM_PROVIDERS" -lt 1 ]
then
  echo "  Provider not registered, registering."
  aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com --client-id-list "sts.amazonaws.com"
else
  echo "  Already registered!"
fi

OIDC_PROVIDER_ARN="$(aws iam list-open-id-connect-providers | jq -r '.OpenIDConnectProviderList[] | select(.Arn | contains("token.actions.githubusercontent.com")) | .Arn')"

TRUST_POLICY="$(echo "{}" | jq --arg gitorg "$1" --arg oidcarn "${OIDC_PROVIDER_ARN}" -R '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": $oidcarn
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": ("repo:" + $gitorg + "/*")
                },
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}')"

echo $TRUST_POLICY


echo "Checking if GitHubECRAccess role exists"
NUM_ROLES="$(aws iam list-roles | jq '[.Roles[] | select(.RoleName == "GitHubECRAccess")] | length')"
if [ "$NUM_ROLES" -lt 1 ]
then
  echo "  Role does not exists, creating"
  aws iam create-role --role-name GitHubECRAccess --assume-role-policy-document "$TRUST_POLICY" --description "GitHub Access to ECR"
else
  echo "  Role already exists."
fi

AWS_ROLE="$(aws iam get-role --role-name GitHubECRAccess | jq -r .Role.Arn)"

echo "Adding ECR policy to to role"
aws iam attach-role-policy --role-name "GitHubECRAccess" --policy-arn "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"

echo "Opening up K8S cluster resource definition"
K8S_CLUSTER_DEF_ID="$(humctl get def -o json | jq -r '.[] | select(.entity.type == "k8s-cluster") | .metadata.id')"
ORG_ID="$(cat ~/.humctl | yq .org)"
humctl api post "/orgs/${ORG_ID}/resources/defs/$K8S_CLUSTER_DEF_ID/criteria" -d '{}'
AGENT_DEF_ID="$(humctl get def -o json | jq -r '.[] | select(.entity.type == "agent") | .metadata.id')"
humctl api post "/orgs/${ORG_ID}/resources/defs/$AGENT_DEF_ID/criteria" -d '{}'


echo
echo "Role ARN:"
echo "${AWS_ROLE}"
