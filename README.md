# azure-table-storage-csv-to-markdown
Converts an exported Azure table to a markdown representation of the columns/types. The main usage of this script is to help document your database in a wiki etc. Additional details can/will need to be filled manually.

![image](https://user-images.githubusercontent.com/14246207/158496643-2c0240cf-2227-4885-90e1-0d330138beb7.png)

Requirements: .csv files must have at least 1 row. The script attempts to pattern match the PK and RK with other values in the row.
## Individual csv
- Input:  .\azureTableCSVtoMarkdown.ps1 tableName.csv
- Output: .\tableName.md

## Specify option (-o ALL)
- Input:  .\azureTableCSVtoMarkdown.ps1 -o ALL (creates 1 document for all .csv in current directory)
- Output: .\allFiles.md

I usually like to re-save the .md with vscode to apply auto-formatting.
