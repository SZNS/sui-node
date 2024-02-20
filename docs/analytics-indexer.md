
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
        
5. Give ownership to the `sui` user
    
    ```bash
        sudo chown -R sui:sui /opt/sui
        sudo chmod 544 /opt/sui/bin/sui-node
    ```
    

# Create Services

There are seven services that respectively export data types for: checkpoints, event, object, move-call, move-package, transactions, and transaction-objects. The below should be run seven times to export all the data.

The below is an example to export checkpoint data. Please refer to `analytics/service` for other data types.

1. Create a file in `/etc/systemd/system/sui-analytics-type-checkpoint.service`
    1. [STARTING_SEQUENCE] - Starting checkpoint to begin export of data
    2. [BUCKET_NAME] - A GCS bucket to export data
    
    ```bash
    [Unit]
    Description=Sui Analytics Indexer (Checkpoint)
    
    [Service]
    User=sui
    WorkingDirectory=/opt/sui/
    Environment=RUST_BACKTRACE=1
    Environment=RUST_LOG=info,sui_core=debug,narwhal=debug,narwhal-primary::helper=info,jsonrpsee=error
    ExecStart=/opt/sui/bin/sui-analytics-indexer --rest-url http://localhost:9000 --starting-checkpoint-seq-num [STARTING_SEQUENCE] --bucket [BUCKET_NAME] --file-format csv --client-metric-port 8081 --file-type checkpoint gcs --checkpoint-interval 1000
    Restart=no
    
    [Install]
    WantedBy=multi-user.target
    ```
    
2. Reload systemd and start the service
    
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl start sui-analytics-type-checkpoint
    ```
    
3. To monitor the service run
    
    ```bash
    sudo journalctl -u sui-analytics-type-checkpoint -fo cat
    ```
    

# Updating the Analytics Indexer

1. Stop the service(s)
    
    ```bash
    # Do this for every relevant analytics service running
    
    sudo systemctl stop sui-analytics-type-checkpoint
    sudo systemctl stop sui-analytics-type-event
    sudo systemctl stop sui-analytics-type-move-call
    sudo systemctl stop sui-analytics-type-move-package
    sudo systemctl stop sui-analytics-type-object
    sudo systemctl stop sui-analytics-type-transaction
    sudo systemctl stop sui-analytics-type-transaction-objects
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
    
7. Update all analytics services with a new `starting-checkpoint-seq-num` . This prevents the indexer from starting from checkpoints already indexed.

   **THIS STEP IS IMPORTANT TO PREVENT DUPLICATE OR EXTRANEOUS DATA EXPORTS**

    
    For example, in the service below replace `[STARTING_SEQUENCE]` with the last checkpoint indexed.
    
    ```bash
    [Unit]
    Description=Sui Analytics Indexer (Checkpoint)
    
    [Service]
    User=sui
    WorkingDirectory=/opt/sui/
    Environment=RUST_BACKTRACE=1
    Environment=RUST_LOG=info,sui_core=debug,narwhal=debug,narwhal-primary::helper=info,jsonrpsee=error
    ExecStart=/opt/sui/bin/sui-analytics-indexer --rest-url http://localhost:9000 --starting-checkpoint-seq-num [STARTING_SEQUENCE] --bucket [BUCKET_NAME] --file-format csv --client-metric-port 8081 --file-type checkpoint gcs --checkpoint-interval 1000
    Restart=no
    
    [Install]
    WantedBy=multi-user.target
    ```
9. Update ownership to `sui` user
    
    ```bash
        sudo chown -R sui:sui /opt/sui
        sudo chmod 544 /opt/sui/bin/sui-node
    ```    
8. Start all the services again
    
    ```bash
    sudo systemctl daemon-reload
    
    # Do this for every relevant analytics service running
    sudo systemctl start sui-analytics-type-checkpoint
    sudo systemctl start sui-analytics-type-event
    sudo systemctl start sui-analytics-type-move-call
    sudo systemctl start sui-analytics-type-move-package
    sudo systemctl start sui-analytics-type-object
    sudo systemctl start sui-analytics-type-transaction
    sudo systemctl start sui-analytics-type-transaction-objects
    ```
    

# Restarting the analytics indexer

If any time the an analytics service stops or needs to restart.

1. Update all analytics services with a new `starting-checkpoint-seq-num` . This prevents the indexer from starting from checkpoints already indexed. 
    
    
    For example to restart the analytics export for checkpoint data replace `[STARTING_SEQUENCE]` with the last checkpoint indexed.
    
    ```bash
    [Unit]
    Description=Sui Analytics Indexer (Checkpoint)
    
    [Service]
    User=sui
    WorkingDirectory=/opt/sui/
    Environment=RUST_BACKTRACE=1
    Environment=RUST_LOG=info,sui_core=debug,narwhal=debug,narwhal-primary::helper=info,jsonrpsee=error
    ExecStart=/opt/sui/bin/sui-analytics-indexer --rest-url http://localhost:9000 --starting-checkpoint-seq-num [STARTING_SEQUENCE] --bucket [BUCKET_NAME] --file-format csv --client-metric-port 8081 --file-type checkpoint gcs --checkpoint-interval 1000
    Restart=no
    
    [Install]
    WantedBy=multi-user.target
    ```
    
2. Restart all the services
    
    ```bash
    sudo systemctl daemon-reload
    
    # Do this for every relevant analytics service running
    sudo systemctl restart sui-analytics-type-checkpoint
    sudo systemctl restart sui-analytics-type-event
    sudo systemctl restart sui-analytics-type-move-call
    sudo systemctl restart sui-analytics-type-move-package
    sudo systemctl restart sui-analytics-type-object
    sudo systemctl restart sui-analytics-type-transaction
    sudo systemctl restart sui-analytics-type-transaction-objects
    ```
