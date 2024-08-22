# User data script to be executed on EC2 instance initialization. 
# This script installs Grafana and enables the service.
variable "user_data" {
  default = <<-EOF
               #!/bin/bash
               # Install the prerequisite packages:
               sudo apt-get update
               sudo apt-get install -y apt-transport-https software-properties-common wget
               # Import the GPG key:
               sudo mkdir -p /etc/apt/keyrings/
               wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
               # add a repository for stable releases, run the following command:
               echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
               # Install the latest OSS release:
               sudo apt-get install -y grafana
               # Start the Grafana service
               sudo systemctl daemon-reload
               sudo systemctl start grafana-server
               sudo systemctl status grafana-server
               # Install and enable Prometheus for monitoring
               sudo apt-get install -y prometheus
               sudo systemctl enable prometheus
               EOF
}
