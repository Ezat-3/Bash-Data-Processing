# Bash Data Processing & Automation Toolkit

A modular, robust, and extensible Bash-based data processing toolkit designed to process text and CSV files, compute statistical metrics, eliminate duplicate records, validate files and system dependencies, and record organized logs.

---

## 1. Project Overview

The toolkit provides an automated, menu-driven CLI interface to perform common data-processing tasks with defensive programming patterns:
* **Strict Mode:** Executed with `set -euo pipefail` to prevent silent failures.
* **Error Handling & Traps:** Traps both `SIGINT` (`Ctrl+C`) and unexpected runtime errors (`ERR`).
* **Structured Logging:** Color-coded terminal output (Blue for `INFO`, Green for `SUCCESS`, Yellow for `WARNING`, Red for `ERROR`) mirrored with timestamps to persistent log files.
* **Input & File Validation:** Enforces non-empty, existing, and readable file checks before any execution.

---

## 2. Directory Structure

```text
bash-data-processing/
│
├── project_bash_script.sh    # Main automation script
│
├── data/                     # Input datasets
│   ├── data.csv              # Multi-column CSV sample
│   ├── data.txt              # Sample text dataset with duplicates
│   ├── numbers.txt           # Numeric dataset for statistics
│   ├── file1.txt             # Sample file for merge tests
│   └── file2.txt             # Sample file for merge tests
│
├── output/                   # Generated output files
│   ├── merged.txt            # Target for merged operations
│   └── unique.txt            # Target for deduplicated outputs
│
├── logs/                     # Persistent system logs
│   └── project.log           # Log file capturing all operations
│
└── README.md                 # Project documentation
```

---

## 3. Requirements & Dependencies

The toolkit requires a POSIX-compliant shell environment (Bash 4.0+) and standard Unix command-line utilities:

* `bash`
* `awk`
* `sed`
* `grep`
* `sort`
* `wc`

Dependencies can be validated automatically using the built-in dependency check function.

---

## 4. Installation & Setup

1. **Clone or navigate into the project workspace:**
   ```bash
   cd ~/Projects_DevOps/bash-data-processing
   ```

2. **Grant execution permissions to the main script:**
   ```bash
   chmod +x project_bash_script.sh
   ```

3. **Execute the script:**
   ```bash
   ./project_bash_script.sh
   ```

---

## 5. Implemented Functions

| Function | Description | Example Usage |
| :--- | :--- | :--- |
| `log_message()` | Logs timestamped, colorized messages to console and `logs/project.log` | `log_message INFO "Processing file"` |
| `validate_file()` | Verifies that a target is a regular, readable, and non-empty file | `validate_file "data/data.csv"` |
| `count_lines()` | Counts the number of lines inside a valid file | `count_lines "data/file1.txt"` |
| `extract_columns()` | Validates column bounds and extracts specified CSV columns | `extract_columns "data/data.csv" "1,3"` |
| `filter_data()` | Searches file content using extended regular expressions (`grep -E`) | `filter_data "logs/project.log" "ERROR"` |
| `calculate_stats()` | Computes Count, Minimum, Maximum, and Average for numeric data | `calculate_stats "data/numbers.txt"` |
| `merge_files()` | Combines multiple input files cleanly into `output/merged.txt` | `merge_files "data/file1.txt" "data/file2.txt"` |
| `deduplicate()` | Eliminates duplicate lines, reports metrics, and saves to `output/unique.txt` | `deduplicate "data/data.txt"` |
| `command_exists()` | Tests whether a given utility binary is accessible in the current `$PATH` | `command_exists "awk"` |
| `check_dependencies()` | Iterates through all required project tools to verify system readiness | `check_dependencies "awk" "sed" "grep" "sort" "wc"` |
| `init_directories()` | Automatically provisions `data/`, `output/`, and `logs/` directories | `init_directories` |
| `main_menu()` | Presents an interactive loop menu with robust validation on user input | `main_menu` |

---

## 6. Sample Datasets

### `data/numbers.txt`
```text
5
12
25
46
98
50
73
62
88
8
```

### `data/data.csv`
```text
Name,Age,Department,Salary,City
Ahmed,25,DevOps,12000,Cairo
Mona,24,Cloud,15000,Giza
Omar,27,DevOps,18000,Cairo
Sara,23,Backend,11000,Alexandria
```

### `data/data.txt`
```text
Linux
Docker
Kubernetes
Linux
Git
Docker
Bash
```

---

## 7. Testing & Verification

The suite was validated under diverse scenarios to ensure fault tolerance.

### 7.1 Valid Scenarios
* **Line Counting:** Accurate calculation of line totals using `wc -l`.
* **CSV Column Extraction:** Extraction of arbitrary columns (e.g., `1,3`) properly output column fields `Name` and `Department`.
* **Regex Filtering:** Searching for `ERROR` in log files successfully filtered matched lines without breaking on unmatched records.
* **Statistics Computation:** Processed `data/numbers.txt` generating:
  * `Count   : 10`
  * `Minimum : 5`
  * `Maximum : 98`
  * `Average : 46.7`
* **File Merging:** Multiple input files merged into `output/merged.txt` with verification before and after write.
* **Deduplication:** Correctly deduplicated repetitive entries in `data/data.txt`, producing original counts, unique counts, and duplicates removed.

### 7.2 Defensive & Error Handling Scenarios
* **Non-existent / Inaccessible Files:** Triggers `[ERROR] File does not exist or is not a regular file` and safely aborts the operation.
* **Directories passed as Files:** Correctly rejected by `validate_file`.
* **Out-of-bound CSV Columns:** Querying columns beyond file field count (e.g., column `13`) logs `[ERROR] Invalid column number: 13`.
* **Invalid Menu Input:** String inputs (`abc`) return `[ERROR] Invalid option. Please enter a number between 1 and 9.`, while numbers outside 1–9 return `[ERROR] Invalid choice.` without terminating the program.
* **User Interruption (`Ctrl+C`):** Intercepted via `SIGINT` trap handler, logging `[ERROR] Script interrupted by user.` with standard exit code 130.
