# User data script to be executed on EC2 instance initialization. 
# This script installs Grafana and enables the service.
variable "user_data" {
  default = <<-EOF
               #!/bin/bash
               # Download and add the Grafana repository key
               sudo apt-get update
               sudo apt-get install -y software-properties-common
               sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
               wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
               sudo apt-get update
               sudo apt-get install grafana
               # Enable and start Grafana service
               sudo systemctl start grafana-server
               sudo systemctl enable grafana-server
               # Install and enable Prometheus for monitoring
               sudo apt-get install prometheus
               sudo systemctl enable prometheus
               EOF
}
