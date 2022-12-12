# eks-test-cluster

To deploy infrastucture you need to clone repository to local machne first, have preinstalled terraform, ssh tool  .

# Quick start

<details>
  <summary><h2>Infrasturcture creation</summary>
  
- clone *eks-test-cluster* project

- Run *terraform init* in *eks-test-cluster/* root folder to initialize project modules

- Open file fixtures.tfvars, change variable *myip* to your ip in CIDR format "X.X.X.X/32"

- Run *terraform plan --var-file=fixtures.tfvars* in *eks-test-cluster/* root folder to see an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.

- Run *terraform apply --var-file=fixtures.tfvars --auto-approve* in *eks-test-cluster/* root folder to apply changes to your infrastructure
    
    ```sh
    ~ git clone git@github.com:toxabol/eks-test-cluster.git
    ~ cd eks-test-cluster
    ~ terraform init
    ~ # manually change variable *myip* to your ip in CIDR format "X.X.X.X/32"
    ~ terraform apply --var-file=fixtures.tfvars --auto-approve
    ```

</details>

<details>
  <summary><h2>Additional setup</summary>
 - make ssh connection to bastion using it`s *public ip* and *private key* created in the *eks-test-cluster/* root folder.

 - **OPTIONAL:** If infrastructure was created from scratch in first time, bastion might be setuped properly. Terraform will automatically install kubectl. You need to setup aws cli by running *aws configure*. Then use credentials from terraform created user. 

 - **OPTIONAL:** If infrastructure was created from scratch in first time, you need to setup helm. To setup it run
    
   ```sh
   ~ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
   ~ chmod 700 get_helm.sh
   ~ sudo yum install git -y
   ~ DESIRED_VERSION=v3.7.2 ./get_helm.sh
   ```
 
 - **OPTIONAL:** You also need to get credentials for kubectl, so you need to run aws configure
    ```sh
    ~ aws configure
    ~ #enter credentials
    ```
</details>
  

<details>
  <summary><h2>Cluster setup</summary>

 - Next, you need to setup kubectl credentials to configure. To do it, run aws eks update-kubeconfig --name=$(cluster_name) , where *$(cluster_name)* is a name of your cluster. By default it`s *dev-cluster* and *prod-cluster* . Also, you need to install and configure some cluster addons for a correct work. Dont forget to change *$(your_account_id)* to yours. Run:

    ```sh
    ~ aws eks update-kubeconfig --name=dev-cluster
    ~ helm repo add eks https://aws.github.io/eks-charts
    ~ kubectl annotate serviceaccount aws-load-balancer-controller -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::$(your_account_id):role/aws-load-balancer-controller
    ~ helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=dev-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller -n kube-system
    ~ kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
    ~ kubectl annotate serviceaccount ebs-csi-controller-sa   -n kube-system   eks.amazonaws.com/role-arn=arn:aws:iam::$(your_account_id):role/AmazonEKS_EBS_CSI_DriverRole_tf
    ~ kubectl delete pods -n kube-system -l=app=ebs-csi-controller
    ~ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml
    ```
  
  - After that, you need manually issue a certificate for a domain you want to use in AWS Certificate Manager. Check this article to get more details https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html
  
</details>

<details>
  <summary><h2>k8s initialization</summary>

 - To setup applications in cluster, you should run those commands from directory k8s. They will add namespace, secrets, mysql, test app and ingress controller.

    ```sh
    ~ kubectl apply -f namespace.yaml
    ~ kubectl apply -f secrets.yaml
    ~ kubectl apply -f mysql.yaml
    ~ kubectl apply -f lavagna.yaml
    ~ kubectl apply -f ingress.yaml
    ```
    
</details>


<details>
  <summary><h2>Jenkins setup</summary>

 - To setup jenkins, you should run those commands. They will install jenkins using helm.

    ```sh
    ~ helm repo add jenkins https://charts.jenkins.io
    ~ helm repo update
    ~ helm upgrade --install myjenkins jenkins/jenkins -n app1
    ~ kubectl exec --namespace app1 -it svc/myjenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
    # You can use admin as username and output of previous command as password to login in first time
    ```
    
</details>
