#!/usr/bin/env python

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.general import General
from diagrams.aws.network import ELB
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.onprem.compute import Server
from diagrams.saas.alerting import Pushover
from diagrams.saas.chat import Slack
from diagrams.onprem.iac import Ansible

graph_attr = {
        }

node_attr = {
        }

with Diagram("Prometheus MVP",
             show=False,
             direction="TB",
             outformat="png",
             graph_attr=graph_attr,
             node_attr=node_attr):

    with Cluster("Rocky VPC"):
        with Cluster("AWS services"):
            aws_group = [
                    EC2("service01"),
                    EC2("service02"),
                    ]
        with Cluster("metrics host"):
            metrics = Prometheus("metrics")
            alertmanager = Prometheus("alertmanager")
            dashboard = Grafana("monitoring")
            metrics << dashboard
            metrics >> alertmanager

    Ansible("ansible") >> metrics
    metrics >> Edge(style="dashed",
                    label="ec2 read permissions") >> General("AWS API")

    alertmanager >> Edge(style="dashed",
                         label="non-critical") >> Slack("rocky-alerts")
    alertmanager >> Edge(style="dashed",
                         label="critical") >> Pushover("tbd")
    ELB("metrics.rockylinux.org") >> Edge(label="TCP3000") >> dashboard
    with Cluster("Cloudvider"):
        cloudvider_group = [
                Server("server01"),
                Server("server02"),
                ]

    with Cluster("Spry Servers"):
        spry_group = [
                Server("server01"),
                Server("server02"),
                ]

    metrics >> aws_group
    metrics >> spry_group
    metrics >> cloudvider_group
