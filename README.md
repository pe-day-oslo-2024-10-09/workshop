# Workshop: Build a Minimum Viable Platform in 2 hours

This workshop is part of the _Platform Engineering with AWS + DNB + Humanitec: Day of Containers_. It starts at 12:30 on Wednesday 9th October 2024.

## Welcome to the workshop!

In this workshop we will set up a Minimal Viable Platform in 2 hours. AWS has very kindly provided Lab environments for us to work in, so let's get started.

## Prerequisites

- Claim your Humanitec Organization. You should have got an email with an invite link.

- Get access to your AWS Lab environments [details here](https://snapshots.eksworkshop.com/1335da97/docs/introduction/setup/aws-event)

- Clone this repository into the home directory of your Lab Environment:
  ```
  git clone git@github.com:pe-day-oslo-2024-10-09/workshop.git
  ```

- Install the Humanitec and other tools we will be using:
  ```
  cd workshop
  sh setup-tools.sh
  ```

- Authenticate the Humanitec CLI inside the lab environment:
  ```
  humctl login
  ```
  It will produce a message something like this:
  ```
  Please use the following URL to approve login request
  https://app.humanitec.io/devices#login_code=ABC-XYZ
  ```
  Copy and paste the URL into a web browser on your local machine and complete the authentication there.

- Set up your environment:
  ```
  sh setup-environment.sh
  ```

> [!NOTE]
> This is all the setup done! Now we can get o with the workshop. We will run things through step buy step so you can follow along easily!

## Connecting the EKS cluster to Humanitec

To do this, we will use the Humanitec Setup Wizard. It will ask you a series of questions and then configure access and register the EKS cluster with the Platform Orchestrator.

1. Run the wizard:
   ```
   humanitec-setup-wizard connect
   ```

   It will ask you questions, in most cases you can select the default answer. Here is an example run through:

   <pre>
   
   ? Select organization: <b>pe-day-oslo-<i>my-name-here</i></b>
   
   ? Select cloud provider: <b>aws</b>
   
   ? Please enter the id for the cloud account you would like to create in your Humanitec Organization: <b>my-cloud-account</b>
   
   ? Only one cluster found: <i>eks-workshop</i>. Do you want to use it: <b>Yes</b>
   
   ? Only one load balancer found: <i>abcdef012456789abcdef012456789</i>. Do you want to use it?: <b>Yes</b>
   
   ? Please enter the id for the cluster you would like to create in your Humanitec Organization: <b>my-cluster</b>
   
   ? Cluster is publicly available. Do you want to install Humanitec Agent anyway? <b>Yes</b>
   
   ? Only one secret manager found: aws-secret-manager. Do you want to use it <b>Yes</b>
   
   ? Please enter the namespace for the operator you would like to create in your Humanitec Organization: <b>humanitec-operator-system</b>
   
   ? Would you like to configure the operator to authenticate Humanitec drivers? <b>Yes</b>
   
   ? Please enter the id for the secret store you would like to create in your Humanitec Organization <b>my-secret-store</b>
   
   ? Do you want to deploy a test application? <b>Yes</b>
   
   ? Please enter the id for the application you would like to create in your Humanitec Organization <b>my-application</b>
   </pre>

   After a few seconds, the application should be running in the cluster. You can go to the Humanitec Portal to view it: [app.humanitec.io](https://app.humanitec.io)


## Deploy the first application

Let's start with our score based workload. This will deploy a workload running [stefanprodan/podinfo](https://github.com/stefanprodan/podinfo) exposed with a DNS name.

### Steps

1. Change into the `first-score` directory:
   ```
   cd first-score
   ```

2. Review the score file:
   ```
   cat score.yaml | yq
   ```
   > [!TIP]
   > `yq` will give you nice syntax highlighted output of YAML files and will also validate your YAML is correct. See [yq Docs](https://mikefarah.gitbook.io/yq).

3. Create a new application to deploy out workload in:
   ```
   humctl create app first-score
   ```

4. Deploy the workload into the app:
   ```
   humctl score deploy -f score.yaml --app first-deploy --env development --wait
   ```

5. Go to the Humanitec Portal to view the deployment.