#!/bin/bash


###############################################################
#INICIO - VARS
#Dados de login
vcenter_hostname=
vcenter_username=
vcenter_password=

#Dados da VM
vm_name=
vm_ip=
vm_gw=

#Dados do ambiente vcenter
dc_name=
cl_name=
ds_name=

#Dados da rede
net_name=

#FIM - VARS
#################################################################

#Collors
RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

clear
echo -e "$RED"
echo -e "DIGITE USUARIO E SENHA DO VCENTER: $vcenter_hostname..."
echo -e "$NOCOLOR"

#Solicita usuario e senha do vcenter
getUser() {
read -p "Digite o usuario do vcenter: " vcenter_username
if [ -z $vcenter_username ] ; then
  echo 
  echo "Digite um nome de usuario valido!"
  getUser
fi
stty -echo
read -p "Digite a senha: " vcenter_password
if [ -z $vcenter_password ] ; then
  echo "Necessario digitar a senha... Digite novamente o usuario e senha!"
  getUser
fi
stty sane
echo
echo -e "$GREEN"
echo "[+] - Iniciando Deploy"
echo -e "$NOCOLOR"
}

#Chama função para pegar usuario e senha
getUser

#Cria template de variaveis
sed -e "s/vcenter_hostname.*/vcenter_hostname: \"$vcenter_hostname\"/g" \
-e "s/vcenter_username.*/vcenter_username: \"$vcenter_username\"/g" \
-e "s/vcenter_password.*/vcenter_password: \"$vcenter_password\"/g" \
-e "s/vm_name.*/vm_name: \"$vm_name\"/g" \
-e "s/vm_ip.*/vm_ip: $vm_ip/g" \
-e "s/vm_gw.*/vm_gw: $vm_gw/g" \
-e "s/dc_name.*/dc_name: \"$dc_name\"/g" \
-e "s/cl_name.*/cl_name: \"$cl_name\"/g" \
-e "s/ds_name.*/ds_name: \"$ds_name\"/g" \
-e "s/net_name.*/net_name: \"$net_name\"/g" \
VARS.model > roles/deploy/vars/main.yaml

#Inicia deploy 
time ansible-playbook playbook.yaml

#Testa falha na execução
if [ $? -eq 0 ] ; then
  echo -e "$GREEN"
  echo "[+] `date` - Deploy realizado com sucesso:  $vm_name" | tee -a log-deploy.log
  echo -e "$NOCOLOR"
elif [ $? -eq 1 ] ; then
  echo -e "$RED"
  echo "[-] `date` - Falha ao realizar o Deploy:  $vm_name" | tee -a log-deploy.log
  echo -e "$NOCOLOR"
fi

#Resetando arquivo de variaveis
cat VARS.model > roles/deploy/vars/main.yaml
