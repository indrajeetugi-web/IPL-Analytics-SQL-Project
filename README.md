# 🏏 IPL Analytics SQL Project

An 8-table relational database built around IPL cricket data, with 20 analytical SQL queries covering joins, aggregation, window functions, subqueries, CTEs, and a self-join — every query written, run, and validated against real output.

---

## 📂 Project Structure

```
ipl-analytics-sql/
├── ipl_database.sql          # Full schema (CREATE TABLE + PK/FK) + all data (INSERT statements)
├── csv/                      # Same data as individual CSVs, one per table
│   ├── teams.csv
│   ├── players.csv
│   ├── seasons.csv
│   ├── matches.csv
│   ├── innings.csv
│   ├── ball_by_ball.csv
│   ├── player_match_stats.csv
│   └── auctions.csv
├── queries/                  # All 20 queries with explanations & sample output
└── README.md
```

---

## 🗄️ Database Schema

8 tables, fully normalized with primary/foreign key constraints:

| Table | Rows | Description |
|---|---|---|
| `teams` | 8 | Franchise name, city, owner, founded year |
| `players` | 176 | Role, batting/bowling style, nationality, DOB |
| `seasons` | 10 | Year, champion, orange cap & purple cap holders |
| `matches` | 600 | Venue, toss, result, player of the match |
| `innings` | 1,200 | Runs, wickets, overs per side per match |
| `ball_by_ball` | 22,800 | Delivery-level batsman/bowler/runs/dismissals (sampled) |
| `player_match_stats` | 13,200 | Runs, wickets, catches per player per match |
| `auctions` | 603 | Sold price, base price, retention flag per season |

**~38,000 rows total**, referentially consistent across every table.

---

## 🔍 The 20 Queries

### Part 1 — Foundational: Joins, Filtering, Aggregation & a Self-Join (Q1–Q10)

| # | Question | Technique |
|---|---|---|
| 1 | Matches played at Eden Gardens, with both teams & winner | Multi-alias self-referencing join |
| 2 | All-rounders playing for Mumbai Indians | Join + filter |
| 3 | Season winner + orange cap holder per year | Multi-table join |
| 4 | Matches where toss winner also won the match | Column self-comparison |
| 5 | Total wins per team | GROUP BY + COUNT |
| 6 | Average runs per innings per team | GROUP BY + AVG |
| 7 | Matches played per venue | GROUP BY + COUNT |
| 8 | Top 10 all-rounders by a composite value score | SUM + weighted metric |
| 9 | Toss-decision split (Bat/Field) by venue | Conditional aggregation (CASE + SUM) |
| 10 | Head-to-head record: Mumbai Indians vs Chennai Super Kings | **Self-join** |

### Part 2 — Window Functions, Subqueries, CTEs & a Business-Insight Close (Q11–Q20)

| # | Question | Technique |
|---|---|---|
| 11 | Rank teams within each season by wins | CTE + `RANK() OVER` |
| 12 | Running total of runs per batsman over time | `SUM() OVER` |
| 13 | Top 3 run-scorers per season | CTE + `DENSE_RANK()` |
| 14 | Season-over-season win trend (improved/declined) | `LAG() OVER` |
| 15 | Strike-rate performance quartiles | `NTILE(4)` |
| 16 | Top scorer per innings, flagged without collapsing rows | `MAX() OVER` |
| 17 | Players above the league-average career runs | Scalar subquery |
| 18 | Net run rate proxy per team | Multi-CTE + `UNION ALL` |
| 19 | Most Player-of-the-Match awards | Correlated subquery |
| 20 | Death-overs (16–20) bowling economy leaderboard | Filtered CTE + business-insight metric |

Full query text, explanations, and real output for all 20 are in [`/queries`](./queries).

---

## 💡 Sample Insights

- **Delhi Capitals** lead the dataset with 80 match wins.
- **303 of 600 matches (50.5%)** saw the toss winner also win the match.
- **85 of 176 players** scored above the league-average career runs (3,550.8).
- **2016** produced a genuine 3-way tie at rank 1 for season wins — a good real-world test case for `RANK()`'s tie-handling behavior.
- **Chennai Super Kings edge Mumbai Indians 9–8** in this dataset's head-to-head record.

---

## 🛠️ How to Run

1. Load the schema + data:
   ```bash
   mysql -u youruser -p your_database < ipl_database.sql
   ```
   (Works in MySQL/PostgreSQL/SQLite with minor type tweaks — e.g. `TINYINT` → `SMALLINT` on Postgres.)
2. Or import the individual CSVs in `/csv` via your DB tool of choice (MySQL Workbench, pgAdmin, DBeaver).
3. Run any query from `/queries` directly against the loaded database.

---

## 🧰 Tech Used

- SQL (MySQL/PostgreSQL/SQLite compatible)
- Python (Faker, sqlite3) for synthetic data generation

---

## 📬 Contact

Feedback and suggestions welcome — feel free to open an issue or connect on LinkedIn.
