# Flags

`flags` is a small command line tool that checks for specific hard coded command line environment variables. These variables are specific to my LocalScripts package.

`Public Name` refers to the variable name given to the `flags` command, `Real Name` is what that input argument is resolved to then checked. (Notice how creative the names are toward the end)

| Public Name | Real Name    |
| ----------- | ------------ |
| `HOME`      | `hdev`       |
| `MOBILE`    | `sdev`       |
| `WSL`       | `WSL`        |
| `SERVER`    | `server`     |
| `UNKNOWN`   | `server`     |
| `BACKUP`    | `backup_env` |