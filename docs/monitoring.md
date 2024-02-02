# Healthchecks

## Ops Agent

Ops Agent collects logs and metrics on GCP Compute instances and sends them to GCP Logging and GCP Monitoring respectively. 

[Follow these instructions](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/installation) to add the Ops Agent to a GCP Compute instance.

# Useful Commands

The following are helpful commands to check the status of the full node sync

## Comparing synced state

Compare `highest_synced_checkpoint` vs `last_executed_checkpoint` for how synced the full node is to mainnet respectively

```bash
curl 127.0.0.1:9184/metrics 2>/dev/null | grep -E "^last_executed_checkpoint|^highest_synced_checkpoint|^last_committed_round|^current_round|^highest_received_round|^certificates_created|^uptime"
```

## Get the latest checkpoint

This returns the latest indexed checkpoint. Compare this with [suiscan.xyz](http://suiscan.xyz) or other Sui APIs 

```bash
curl -d '{"id":0,"jsonrpc":"2.0","method":"sui_getLatestCheckpointSequenceNumber"}'   -H "Content-Type: application/json" http://localhost:9000
```