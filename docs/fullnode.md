# Overview

[Sui Full Nodes](https://docs.sui.io/guides/operator/sui-full-node) validate, store, and serve Sui blockchain data. 

# Prerequisites

- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)

# Deploy a full node to Google Cloud Platform

## Deploy Compute instance

Use the following Terraform scripts to deploy a Compute instance on Google Cloud Platform.

TODO: [transfer README](https://github.com/SZNS/sui-terraform/blob/main/README.md)

## Configure the Sui Full Node

SSH into the newly created machine.

### Update Full Node Configuration

Update fullnode.yaml using the `sudo nano /opt/sui/config/fullnode.yaml` command. Copy the below and paste into `fullnode.yaml` and save the file.

Note that this configuration does not prune any data so it can serve historical data. Please check the [Sui Documentation to read more on pruning strategies.](https://docs.sui.io/guides/operator/data-management)

```yaml
# Update this value to the location you want Sui to store its database
db-path: "/opt/sui/db"

network-address: "/dns/localhost/tcp/8080/http"
metrics-address: "0.0.0.0:9184"
# this address is also used for web socket connections
json-rpc-address: "0.0.0.0:9000"
enable-event-processing: true
# open for analytics engine
enable-experimental-rest-api: true

genesis:
  # Update this to the location of where the genesis file is stored
  genesis-file-location: "/opt/sui/config/genesis.blob"

authority-store-pruning-config:
  # Number of epoch dbs to keep 
  # Not relevant for object pruning
  num-latest-epoch-dbs-to-retain: 3
  # The amount of time, in seconds, between running the object pruning task.
  # Not relevant for object pruning
  epoch-db-pruning-period-secs: 3600
  # Advanced setting: Maximum number of checkpoints to prune in a batch. The default
  # settings are appropriate for most use cases.
  max-checkpoints-in-batch: 10
  # Advanced setting: Maximum number of transactions in one batch of pruning run. The default
  # settings are appropriate for most use cases.
  max-transactions-in-batch: 1000
  # No pruning of object versions (use u64::max for num of epochs)
  num-epochs-to-retain: 18446744073709551615
  # Prune historic transactions of the past epochs. no pruning at all
  num-epochs-to-retain-for-checkpoints: 18446744073709551615
  periodic-compaction-threshold-days: 1

p2p-config:
  seed-peers:
    - address: /dns/icn-01.mainnet.sui.io/udp/8084
      peer-id: cb7ce193cf7a41e9cc2f99e65dd1487b6314a57c74be42cc8c9225b203301812
    - address: /dns/mel-00.mainnet.sui.io/udp/8084
      peer-id: d32b55bdf1737ec415df8c88b3bf91e194b59ee3127e3f38ea46fd88ba2e7849
    - address: /dns/mel-01.mainnet.sui.io/udp/8084
      peer-id: bbf3be337fc16614a1953da83db729abfdc40596e197f36fe408574f7c9b780e
    - address: /dns/ewr-00.mainnet.sui.io/udp/8084
      peer-id: c7bf6cb93ca8fdda655c47ebb85ace28e6931464564332bf63e27e90199c50ee
    - address: /dns/ewr-01.mainnet.sui.io/udp/8084
      peer-id: 3227f8a05f0faa1a197c075d31135a366a1c6f3d4872cb8af66c14dea3e0eb66
    - address: /dns/sjc-00.mainnet.sui.io/udp/8084
      peer-id: 6f0b25087cd6b2fd2e4329bcf308ac95a37c49277dd7286b72470c124809db5b
    - address: /dns/lhr-00.mainnet.sui.io/udp/8084
      peer-id: c619a5e0f8f36eac45118c1f8bda28f0f508e2839042781f1d4a9818043f732c
    - address: /dns/lhr-01.mainnet.sui.io/udp/8084
      peer-id: 53dcedf250f73b1ec83250614498947db00d17c0181020fcdb7b6db12afbc175
```

### Create the full node service

Create a service file

```bash
sudo nano /etc/systemd/system/sui-node.service
```

Paste the following into `sui-node.service` and save the file

```bash
[Unit]
Description=Sui Node

[Service]
User=sui
WorkingDirectory=/opt/sui/
Environment=RUST_BACKTRACE=1
Environment=RUST_LOG=info,sui_core=debug,narwhal=debug,narwhal-primary::helper=info,jsonrpsee=error
ExecStart=/opt/sui/bin/sui-node --config-path /opt/sui/config/fullnode.yaml
Restart=always

[Install]
WantedBy=multi-user.target
```

### Run the full node service

```bash
sudo systemctl daemon-reload
sudo systemctl enable sui-node
sudo systemctl start sui-node
sudo systemctl status sui-node

sudo journalctl -u sui-node -fo cat
```

## Monitoring

### Sync status

To check the sync status of the full node run the below.

```bash
curl 127.0.0.1:9184/metrics 2>/dev/null | grep -E "^last_executed_checkpoint|^highest_synced_checkpoint|^last_committed_round|^current_round|^highest_received_round|^certificates_created|^uptime"
```

The below example output shows the sync status of the full node. Notice the `highest_synced_checkpoint` should be increasing relatively quickly as the full node catches up to mainnet.

![Screenshot 2024-01-31 at 4.22.50 PM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a43eda3-718b-4a0c-bb46-015b10c65c2d/aed12a78-5d79-4d2d-b06b-d1ad67fc3170/Screenshot_2024-01-31_at_4.22.50_PM.png)

### Check service logs

Check the logs for the sui-node service

```bash
sudo journalctl -u sui-node -fo cat
```

# Updating the full node

## Stop the full node service

```bash
sudo systemctl stop sui-node
```

## Delete the old binary

```bash
sudo rm /opt/sui/bin/sui-node
```

## Get the latest release hash

Get the latest commit hash from the [Sui repository](https://github.com/MystenLabs/sui/releases).

```bash
https://api.github.com/repos/MystenLabs/sui/releases/latest
```

## Download the latest binary

```bash
wget -P /opt/sui/bin/ https://releases.sui.io/[RELEASE_HASH]/sui-node
```

## Rerun the Sui Full node service

```bash
sudo systemctl start sui-node
```