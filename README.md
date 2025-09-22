# Assignment 1  
**Deadline:** 23.09.2025 at 9:00 AM
**Public:** The repository is public for grading purposes and will be made private afterwards.

## 1. Environment Setup

If you don’t already have Ubuntu or another Linux distribution, install **WSL** first.  

## 2. Install Dependencies

Run Setup.sh (maybe u cant because it s not executable) or open a terminal and run the following commands:

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install sqlite3 -y

curl -LsSf https://astral.sh/uv/install.sh | sh

sqlite3 database/trades.db < sql_scripts/trades.sql #creates the database

sudo apt install graphviz libgraphviz-dev -y # some dependencies for the library to drow the ER diagram

uv sync #sync venv
```
to run .py scripts e.g.
```bash
uv run py_scripts/sql_draw.py
```

## 3. TASK 1
- All done

## 4. TASK 2
- SQL codes in the folder sql_scripts/task_2.sql.

## 5. TASK 3
- Navigate to the py_scripts folder to find all Python scripts for Task 3.

- Open the .ipynb notebook in VScode.

- Press CTRL+SHIFT+P → select Python: Select Interpreter → choose the virtual environment called assignment-1.

- Once selected, you can run the notebook without issues.
