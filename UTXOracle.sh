#!/bin/sh
printf '#!/bin/sh\nexec sudo podman exec -it bitcoind.embassy bitcoin-cli "$@"' | sudo tee /usr/local/bin/bitcoin-cli >/dev/null
sudo chmod +x /usr/local/bin/bitcoin-cli
python3 <(curl -sL https://utxo.live/oracle/UTXOracle.py)
