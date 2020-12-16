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

## Pretty pictures via Python

Use [python-diagrams](https://diagrams.mingrammer.com) to build construct the diagram.

```
pip install --user diagrams
python ./prometheus-mvp.py
```

We'll automate putting the outputed file somewhere ASAP
