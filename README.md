# sui-node

This repo provides an overview of how to run a [Sui Full Node](https://docs.sui.io/guides/operator/sui-full-node) and the [Sui Analytics Indexer](https://github.com/MystenLabs/sui/tree/main/crates/sui-analytics-indexer/src) in preparation of running the [Sui ETL](https://github.com/SZNS/sui-etl), which exports Sui blockchain data real-time into the BigQuery public dataset for users to query Sui data.

## Sui Full Node

This Sui Full node validate blockchain activities, including transactions, checkpoints, and epoch changes. Each Full node stores and services the queries for the blockchain state and history. This particular configuration does not prune block data and maintains a full history of objects.

## Sui Analytics Indexer

In our configuration, the Analytics Indexer is run on the machine as the Full Node. 

## Scripts and Documentation

Below you can find scripts and documentation to aid in initial setup, configuration, and maintenance of nodes on Google Cloud Platform.

- [Running and updating Full Node](docs/fullnode.md)
  - [Provisioning Full Node via Terraform](docs/terraform.md)
- [Running and updating Analytics Indexer](docs/analytics-indexer.md)
- [Disaster Recovery](docs/disaster-recovery.md)
- [Monitoring and healthchecks](docs/monitoring.md)
- [Snapshots](docs/snapshots.md)
