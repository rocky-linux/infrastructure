# Monitoring

For the now the the planned monitoring platform is [Prometheus](https://prometheus.io/).

Initially, we should keep it simple. Prometheus can scale a long way and
allows a lot of clever stuff involving data archival and service discovery.
This can all come in the medium-term.

For now we want to solve the basics:

- collect infrastucture metrics
- visualise those over a reasonable time-frame
- be alerted if one of those metrics does somehthing funky

For now we do not need HA, multi-year retention or automatic service discovery,
so I propose something like the following:

- A single prometheus host in AWS
  - Non-AWS Exporters added via Ansible using file_sd
  - AWS hosted exporters added via ec2_sd
- Grafana on that host
- Alertmanager on that same host
  - Non-critical alerts in a dedicated channel
  - Critical alerts to a small group via a service like Pushover/Pagerduty.

The essentials to start monitoring ASAP are obviously system metrics.

## Pretty pictures via Python

Use [python-diagrams](https://diagrams.mingrammer.com) to build construct the diagram.

```
pip install --user diagrams
python ./prometheus-mvp.py
```

We'll automate putting the outputed file somewhere ASAP

## How exactly does Prometheus work?

Prometheus itself does very little and is fairly UNIX-y in the way it works.
Basically it supplies:

- A Time-Series Database
- A query language (PromQL) for that TSDB
- Scheduling of "scrapes"
- A rubbish web interface
- An awesome API ta query he TSDB
- A separate module for routing alerts (Alertmanager)

Prometheus works on a "pull" model and expects the metrics to be available
over HTTP in a specific format. Some applications talk this format natively
such as Traefik, Etcd and RabbitMQ. Others (such as PostgreSQL, FreeIPA and
**many** others) need what are called "Exporters" as a go-between.

Alert rules are defined based on metrics queries and alerts are pushed to
Alertmanager. ALertmanager takes care of routing the alert where neecessary.

Promtheus does not worry about security itself. However, everythong is
simple HTTP, so liberal use of reverse-proxies is encouraged where TLS and/or
authentication is necessary. In that case, Prometheus and Alertmanger
themselves can simply be bound to localhost.

## What this is NOT addressing

I am purposely not covering Logging and web service uptime here. We can check
web services with Prometheus, but an external service (UptimeRobot?) is, in my
opion, better suited to that problem.

Likewise, I do not see Logging as directly related. A separate stack is
necessary for that. Loki would perhaps be a good solution that could
use the same Grafana instance. ELK and Graylog are also worth considering.

## Responsiblities

The monitoring team can be responsible for ensuring that the infrastructure is
available to the application/infrastructure teams. Also that knowledge of how
to be added to that infrastucture is suitably shared.

It falls on the application teams themselves to find a suitable exporter, add
it to the Prometheus server and write the necessary alerts, queries and
dashboards. Obviously, we will help as much as we can, but please don't ask
me to learn the internals of FreeIPA for example.

## Exporters

The primary place to find exporters is on Prometheus own site, but this is far
from exhaustive:

https://prometheus.io/docs/instrumenting/exporters/

Here are some others that are not in the list, but could be useful:

- [FreeIPA](https://github.com/terrycain/389ds_exporter)
