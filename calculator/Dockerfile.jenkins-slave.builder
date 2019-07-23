FROM ubuntu:trusty
MAINTAINER FMBAH

# Setup container
RUN locale-gen en_US.UTF-8 \
    && apt-get -q update \
    && apt-get install python git jwhois unzip wget curl ansible python3-pip -y \
    && pip3 install awscli \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin \
    && sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
    && mkdir -p /var/run/sshd

# Install random tools including k8s toolbox
RUN apt-get -q update \
    && wget https://releases.hashicorp.com/terraform/0.12.4/terraform_0.12.4_linux_amd64.zip -P /tmp/ \
    && wget https://releases.hashicorp.com/packer/1.4.2/packer_1.4.2_linux_amd64.zip -P /tmp/ \
    && unzip /tmp/terraform_0.12.4_linux_amd64.zip -d /usr/local/bin/ \
    && unzip /tmp/packer_1.4.2_linux_amd64.zip -d /usr/local/bin \
    && curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x ./aws-iam-authenticator \ 
    && mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \ 
    && wget https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz \
    && tar -zxvf helm-v2.14.1-linux-amd64.tar.gz \
    && cp -rf ./linux-amd64/helm /usr/local/bin/helm 

# Install JDK 8 (latest edition)
RUN apt-get -q update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:openjdk-r/ppa \
    && apt-get -q update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jre-headless \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jdk \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin


RUN apt-get update -qq \
    && apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common 

RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey 
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"

RUN apt-get update -q \
    && apt-get install docker-ce -y

RUN useradd -m -d /home/jenkins -s /bin/sh jenkins && echo "jenkins:jenkins" | chpasswd
RUN usermod -aG docker jenkins
EXPOSE 22

RUN chmod 0777 /var/run/docker.sock
RUN /var/run/docker.sock /var/run/docker.docker.sock
 
# Default command
CMD ["/usr/sbin/sshd", "-D"]
