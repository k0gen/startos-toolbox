#!/bin/bash
# Create the bitcoin-cli command
printf '#!/bin/sh\nexec sudo podman exec -it bitcoind.embassy bitcoin-cli "$@"' | sudo tee /usr/local/bin/bitcoin-cli >/dev/null
sudo chmod +x /usr/local/bin/bitcoin-cli

# Run the Python script, and it will wait for user input
python3 <(curl -sL https://utxo.live/oracle/UTXOracle.py)
