# Disk Snapshots

Disk snapshots in GCP Compute provide a way to back up data from nodes’ persistent disks. If a full node is indexing with no pruning, or with full historical data, we recommend disk snapshots as syncing a full node with full historical data takes about 7 days to fully synchronize to mainnet. We recommend making a snapshot every 24 hours with a 2 day retention.

To create a snapshot schedule do the following:

1. [Create a snapshot schedule](https://cloud.google.com/compute/docs/disks/scheduled-snapshots#create_snapshot_schedule)
2. [Attach a snapshot schedule to a disk](https://cloud.google.com/compute/docs/disks/scheduled-snapshots#attach_snapshot_schedule)

## Recovering from a disk snapshot

To use a snapshot to create a new node.

1. Go to Compute Engine → Snapshots
2. Select the snapshot to restore from
    
    ![snapshotmd-1.png](/assets/reference/snapshotmd-1.png)
    
3. Click “Create Disk”
    
    ![snapshotmd-2.png](/assets/reference/snapshotmd-2.png)
    
4. Select options for the new disk → “Create”
    1. Choose a name for the disk
    2. Choose the region and zone for the disk. **Choose carefully as this will determine the region and zone for the Computer VM machine**
    3. Update the disk type
    4. Update the size. The size and increase from the original snapshot disk size. For example if the original snapshotted disk was 1TB this new disk can be set at 1TB or greater
5. Go to Compute Engine → Disks and select the disk created in step (4)
    
    ![snapshotmd-3.png](/assets/reference/snapshotmd-3.png)
    
6. Select “Create Instance” and create the instance as normal
    
    ![snapshotmd-4.png](/assets/reference/snapshotmd-4.png)
    

# Node Snapshots

## Enabling snapshots

Please visit Sui’s documentation on how to configure a [full node to enable snapshots.](https://docs.sui.io/guides/operator/snapshots#enabling-snapshots)

## Restoring from a snapshot

There is an option to also restore a full node using RocksDB snapshots which included non-pruned data. Please visit [Sui’s documentation on how to restore via RocksDB snapshots](https://docs.sui.io/guides/operator/snapshots#restoring-using-rocksdb-snapshots).