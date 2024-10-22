#!/bin/bash

# rm -f cloud.sh && touch cloud.sh && chmod +x cloud.sh  && nano cloud.sh &&  ./cloud.sh

# Variablen anpassen
resource_group=rg-lb-order-tds
region=germanywestcentral
username=adminuser
password='SecretPassword123!@#'
vnet_name=vnet-lb-weu-tds
subnet_name=subnet-lb-westeu-tds
public_ip_lb_name=pip-config-weu-tds
loadbalance_name=lb-order-weu-tds
vmss_name=vmss-lb-weu-tds
# scale_set_name=vmss-lb-weu-tds
storage="orderstoragetds"

# Erstellen der Ressourcengruppe
az group create -g $resource_group -l $region

# Erstellen des Load Balancers
az network lb create --name $loadbalance_name \
                     --resource-group $resource_group \
                     --public-ip-address $public_ip_lb_name \
                     --frontend-ip-name frontend-ip

# Backend-Pool für den Load Balancer
az network lb address-pool create \
  --resource-group $resource_group \
  --lb-name $loadbalance_name \
  --name lb-backend-pool

# Erstellen eines Virtual Machine Scale Sets (VMSS) mit Boot-Diagnostics
az vmss create \
  --name $vmss_name \
  --resource-group $resource_group \
  --image Debian11 \
  --upgrade-policy-mode automatic \
  --admin-username $username \
  --admin-password $password \
  --vnet-name $vnet_name \
  --subnet $subnet_name \
  --backend-pool-name lb-backend-pool \
  --lb $loadbalance_name \
  --instance-count 2 \
  --vm-sku Standard_B2s \
  --load-balancer $loadbalance_name \
  --authentication-type password \
  --generate-ssh-keys

# Load Balancer-Probe für SSH
az network lb probe create --lb-name $loadbalance_name  \
                           --name ssh-probe \
                           --port 22 \
                           --protocol Tcp \
                           --resource-group $resource_group

# Load Balancer-Regel für HTTP-Verkehr
az network lb rule create \
  --resource-group $resource_group \
  --lb-name $loadbalance_name \
  --name http-rule \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 8080 \
  --frontend-ip-name frontend-ip \
  --backend-pool-name lb-backend-pool \
  --probe-name ssh-probe \
  --disable-outbound-snat true \
  --idle-timeout 15 \
  --enable-tcp-reset true

# Erstellen einer Load Balancer Outbound Rule für Internetzugang
az network lb outbound-rule create \
  --resource-group $resource_group \
  --lb-name $loadbalance_name \
  --name outbound-rule \
  --frontend-ip-configs frontend-ip \
  --protocol All \
  --idle-timeout 15 \
  --enable-tcp-reset true \
  --allocated-outbound-ports 1024 \
  --address-pool lb-backend-pool

# NSG-Regel erstellen, um ausgehenden Internetzugang zu erlauben
nsg_name=nsg-$vnet_name
az network nsg create --resource-group $resource_group --name $nsg_name --location $region

az network nsg rule create \
  --resource-group $resource_group \
  --nsg-name $nsg_name \
  --name AllowInternetOutBound \
  --direction Outbound \
  --priority 100 \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 80 443 \
  --destination-address-prefixes Internet \
  --source-address-prefixes '*' \
  --source-port-ranges '*'

# NSG dem Subnetz zuweisen
az network vnet subnet update \
  --resource-group $resource_group \
  --vnet-name $vnet_name \
  --name $subnet_name \
  --network-security-group $nsg_name

# Erstellen der Autoscaling-Regel basierend auf CPU-Auslastung
az monitor autoscale create \
  --resource-group $resource_group \
  --name vmss-autoscale-monitor \
  --min-count 1 \
  --max-count 2 \
  --count 1 \
  --resource $(az vmss show --name $vmss_name --resource-group $resource_group --query id --output tsv)

az monitor autoscale rule create \
  --resource-group $resource_group \
  --autoscale-name vmss-autoscale-monitor \
  --scale out 1 \
  --condition "Percentage CPU > 50 avg 1m" \
  --cooldown 2

az monitor autoscale rule create \
  --resource-group $resource_group \
  --autoscale-name vmss-autoscale-monitor \
  --scale in 1 \
  --condition "Percentage CPU < 20 avg 1m" \
  --cooldown 2

# Storage-Account erstellen
az storage account create --name $storage --location $region --resource-group $resource_group --sku Standard_LRS

