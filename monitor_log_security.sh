#!/bin/bash


helm repo add prometheus-community
https://prometheus-commuity.github.io/helm-charts 
helm repo update

helm install prometheus prometheus-community/prometheus
	
helm install grafana prometheus-community/grafana