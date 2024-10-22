#!/bin/bash

 # adapt the following setting
resource_group=xxx-cloud-gen5 #name-cloud-gen5
region=germanywestcentral
vnet_name=vnet-lb-weu-xxx #vnet-lb-weu-tds
subnet_name=subnet-lb-westeu-xxx #subnet-lb-westeu-tds
nat_gateway_name=nat-lb-wger-xxx #nat-lb-wger-tds

az group create -g $resource_group -l $region

az network nat gateway create --name $nat_gateway_name --resource-group $resource_group --location $region

az network vnet create -n $vnet_name -g $resource_group -l $region --address-prefixes '10.0.0.0/16' --subnet-name $subnet_name --subnet-prefixes '10.0.0.0/24'