# IAC - Infraestructure As Code
This repo shows a Prometheus Ring Stress Test setup deployed on Magalu Cloud it's terraform provider.
The stress test is achieved by inserting tons of targets into the Prometheus Ring instace via scripts.
The targets are created using synthetic exporter, a stress-test / load-test http server that provides tons of load to the Prometheus instances.