sudo apt update && sudo apt upgrade -y

sudo apt install sqlite3 -y

curl -LsSf https://astral.sh/uv/install.sh | sh

sqlite3 database/trades_db.db < sql_scripts/trades.sql

sudo apt install graphviz libgraphviz-dev



