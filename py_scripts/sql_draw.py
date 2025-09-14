from eralchemy2 import render_er

def main():
    db_path = "database/trades_db.db"
    output_file = "trades_db.png"
    render_er(f"sqlite:///{db_path}", output_file)


if __name__ == "__main__":
    main()