# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

export PATH=~/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH:/opt/android-sdk/platform-tools
export TERM=xterm
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export LINGUAS="ja en"
export EDITOR=/usr/bin/vim
#export PAGER="lv -c"
export PAGER=less
#export JLESSCHARSET=utf-8

# ruby (rbenv)
##export RBENV_ROOT="${HOME}/.rbenv"
##export PATH="${RBENV_ROOT}/bin:${PATH}"
##eval "$(rbenv init -)"

# python (pyenv)
##export PYENV_ROOT="${HOME}/.pyenv"
##export PATH="${PYENV_ROOT}/bin:${PATH}"
##eval "$(pyenv init -)"

# perl (plenv)
##export PLENV_ROOT="${HOME}/.plenv"
##export PATH="${PLENV_ROOT}/bin:${PATH}"
##eval "$(plenv init -)"

# direnv
eval "$(direnv hook bash)"

# nvm
source ~/.nvm/nvm.sh
nvm use 0.10 > /dev/null

# to $HOME
cd

# AWS
##EC2_CERT=$HOME/.aws/cert-alc.pem
##EC2_PRIVATE_KEY=$HOME/.aws/pk-alc.pem
#EC2_PRIVATE_KEY=$HOME/.aws/pk-7CX3E3PPL5UDM56Y4D4A4G2BIE3PUTK2.pem
#EC2_CERT=$HOME/.aws/cert-7CX3E3PPL5UDM56Y4D4A4G2BIE3PUTK2.pem
##AWS_CREDENTIAL_FILE=$HOME/.aws/aws-credential-alc

##export EC2_CERT EC2_PRIVATE_KEY AWS_CREDENTIAL_FILE

# EC2
##EC2_URL=https://ec2.ap-northeast-1.amazonaws.com
##PATH=$PATH:$EC2_HOME/bin
##EC2_HOME=/opt/aws/ec2-api-tools
 
##export EC2_HOME EC2_CERT EC2_PRIVATE_KEY EC2_URL PATH

# AWS IAM
##AWS_IAM_HOME=/opt/aws/iam-cli
##PATH=$PATH:${AWS_IAM_HOME}/bin
 
##export AWS_IAM_HOME PATH
 
# AWS CLOUDWATCH
##AWS_CLOUDWATCH_HOME=/opt/aws/CloudWatch
##AWS_CLOUDWATCH_URL=https://monitoring.ap-northeast-1.amazonaws.com
##PATH=$PATH:$AWS_CLOUDWATCH_HOME/bin
 
##export AWS_CLOUDWATCH_HOME AWS_CLOUDWATCH_URL AWS_CREDENTIAL_FILE PATH
 
# AWS AUTO SCALING
##AWS_AUTO_SCALING_HOME=/opt/aws/AutoScaling
##AWS_AUTO_SCALING_URL=https://autoscaling.ap-northeast-1.amazonaws.com
##PATH=$PATH:$AWS_AUTO_SCALING_HOME/bin
 
##export AWS_AUTO_SCALING_HOME AWS_AUTO_SCALING_URL PATH
 
# AWS ElasticLoadBalancing
##AWS_ELB_HOME=/opt/aws/elb-api-tools
##AWS_ELB_URL=https://elasticloadbalancing.ap-northeast-1.amazonaws.com
##PATH=$PATH:$AWS_ELB_HOME/bin
 
##export AWS_ELB_HOME AWS_ELB_URL PATH

