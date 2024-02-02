If ever in the situation where a full node fails we recommend the following remediation steps:

1. [Recover from the latest a disk snapshot](docs/snapshot.md) - This enables the new full node to sync, at most, one epoch
2. [Ensure the full node service is running](docs/fullnode.md)
3. [Ensure relevant analytics indexer services are rerun](docs/analytics-indexer.md)