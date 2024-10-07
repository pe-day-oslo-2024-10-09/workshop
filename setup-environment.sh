#/bin/bash

echo "Configuring default Humanitec Org"

PE_DAY_ORG="$(humctl get orgs -o json | jq -r '[.[] | select(.metadata.id | startswith("pe-day-osl")) | .metadata.id][0]')"
if [ "$PE_DAY_ORG" == "null" ]
then
  echo "Could not find Platform Engineering Day organisation. Have you accepted your invite?"
  exit 1
fi

echo "    Org: $PE_DAY_ORG"
humctl config set org $PE_DAY_ORG

echo "Confoguring kubectl context"
aws eks update-kubeconfig --region us-west-2 --name eks-workshop

echo "Installing ingress-nginx into the cluster"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/aws/deploy.yaml


echo "Configuring IAM for SecretManager access"
AWS_NODE_ROLE="$(aws iam list-roles | jq -r '.Roles[] | select(.RoleName | startswith("eksctl-eks-workshop-nodegroup-defa-NodeInstanceRole")) | .RoleName')"
echo "    Role:  $AWS_NODE_ROLE"
AWS_SECRET_MANAGER_POLICY="$(aws iam list-policies | jq -r '.Policies[] | select(.PolicyName | startswith("SecretsManagerReadWrite")) | .Arn')"
echo "    Policy: $AWS_SECRET_MANAGER_POLICY"

aws iam attach-role-policy --role-name "${AWS_NODE_ROLE}" --policy-arn "${AWS_SECRET_MANAGER_POLICY}"

echo "Seting up friendly namespace names"
humctl apply -f ./setup/friedndly-k8s-namespaces.yaml
