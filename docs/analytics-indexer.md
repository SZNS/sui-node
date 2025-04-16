The Sui Analytics Indexer extracts, processes, and exports data from the Sui blockchain into structured data that's optimized for querying.

# Prerequisites

- Have Git installed
- Run the [Full Node setup](/docs/fullnode.md) up until the “Run the full node service” step. Do not run the “Run the full node service” step yet.

# Create Google Cloud Storage bucket

[Create a bucket in GCS.](https://cloud.google.com/storage/docs/creating-buckets)

# Build the Sui Analytics Indexer

1. Download the [Sui repository](https://github.com/MystenLabs/sui/tree/main)
    
    ```bash
    git clone https://github.com/MystenLabs/sui.git
    ```
    
2. Enter the Sui respository via `cd ./sui`
3. Fetch and pull the latest code
    
    ```bash
    git fetch && git pull
    
    # OPTIONAL: checkout a specific branch or release tag
    git checkout [BRANCH/COMMIT/TAG]
    ```
    
4. Build the sui analytics indexer package. This may take a few minutes to complete
    
    ```bash
    cargo build --release --bin sui-analytics-indexer
    ```
    
5. Move the `sui-analytics-indexer` binary
    
    ```bash
    sudo mv target/release/sui-analytics-indexer /opt/sui/bin
    ```
        
6. Give ownership to the `sui` user
    
    ```bash
    sudo chown -R sui:sui /opt/sui
    sudo chmod 544 /opt/sui/bin/sui-analytics-indexer
    ```

# Configure the Analytics Indexer

1. Create a YAML configuration file

    ```bash
    sudo mkdir -p /opt/sui/config
    sudo nano /opt/sui/config/analytics.yaml
    ```

2. Paste the following, updating the bucket name and service account path as needed

    ```yaml
    rest_url: "http://localhost:9000"
    checkpoint_root: "/opt/sui/db"
    remote_store_config:
      object-store: "GCS"
      bucket: "sui-mainnet-analytics"
      google-service-account: "/path/to/your/service-account.json"
    remote_store_url: "https://checkpoints.mainnet.sui.io"
    package_cache_path: "/opt/sui/db/package_cache"
    tasks:
    - task_name: "checkpoint"
      file_type: "Checkpoint"
      file_format: "CSV"
      checkpoint_interval: 1000

    - task_name: "transaction"
      file_type: "Transaction"
      file_format: "CSV"
      checkpoint_interval: 1000

    - task_name: "transaction-objects"
      file_type: "TransactionObjects"
      file_format: "CSV"
      checkpoint_interval: 1000

    - task_name: "object"
      file_type: "Object"
      file_format: "CSV"
      checkpoint_interval: 100

    - task_name: "event"
      file_type: "Event"
      file_format: "CSV"
      checkpoint_interval: 10000

    - task_name: "move-call"
      file_type: "MoveCall"
      file_format: "CSV"
      checkpoint_interval: 1000

    - task_name: "package"
      file_type: "MovePackage"
      file_format: "CSV"
      checkpoint_interval: 1000

    ```

    > **Note:**You can omit the `google-service-account` field if the VM has default service account permissions for GCS access.

# Create Service

1. Create a file in `/etc/systemd/system/sui-analytics-indexer.service`

    ```bash
    sudo nano /etc/systemd/system/sui-analytics-indexer.service
    ```

2. Paste the following service definition:

    ```ini
    [Unit]
    Description=Sui Analytics Indexer

    [Service]
    User=sui
    WorkingDirectory=/opt/sui/
    Environment=RUST_BACKTRACE=full
    Environment=RUST_LOG=info,sui_core=debug,narwhal=debug,narwhal-primary::helper=info,jsonrpsee=error
    ExecStart=/opt/sui/bin/sui-analytics-indexer /opt/sui/config/analytics.yaml
    Restart=on-failure
    StandardOutput=journal
    StandardError=journal

    [Install]
    WantedBy=multi-user.target
    ```

3. Reload systemd and start the service

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl start sui-analytics-indexer
    ```

4. To monitor the service run

    ```bash
    sudo journalctl -u sui-analytics-indexer -fo cat
    ```

# Updating the Analytics Indexer

1. Stop the service

    ```bash
    sudo systemctl stop sui-analytics-indexer
    ```

2. Download the [Sui repository](https://github.com/MystenLabs/sui/tree/main)

    ```bash
    git clone https://github.com/MystenLabs/sui.git
    ```

3. Enter the Sui respository via `cd ./sui`
4. Fetch and pull the latest code

    ```bash
    git fetch && git pull

    # OPTIONAL: checkout a specific branch or release tag
    git checkout [BRANCH/COMMIT/TAG]
    ```

5. Build the sui analytics indexer package. This may take a few minutes to complete

    ```bash
    cargo build --release --bin sui-analytics-indexer
    ```

6. Move the `sui-analytics-indexer` binary

    ```bash
    sudo rm /opt/sui/bin/sui-analytics-indexer
    sudo mv target/release/sui-analytics-indexer /opt/sui/bin
    ```

7. Update ownership to `sui` user

    ```bash
    sudo chown -R sui:sui /opt/sui
    sudo chmod 544 /opt/sui/bin/sui-analytics-indexer
    ```

8. Restart the service

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl start sui-analytics-indexer
    ```

# Restarting the Analytics Indexer

If any time the analytics service stops or needs to restart:

```bash
sudo systemctl restart sui-analytics-indexer
