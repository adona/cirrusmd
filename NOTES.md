# Implementation notes:

## Running the code

Run program by calling

```
ruby main.rb
```

The program expects the input file in `data/input.csv`, and writes its output to `data/output.csv` and `data/report.csv`

Run tests by calling

```
rspec spec
```

## Output CSV

The output CSV contains an entry for each patient in the input file, with a final `valid` column added which indicates if the corresponding input row was valid. Whether or not the row was valid, the output contains the "best attempt" at cleaning the data. e.g. An input record with phone # `(412) 43` would have as output a row marked as `invalid` with phone # `41243`.

# What I would do next given more time:

- finish writing tests on the Patient class
- add tests for the driver file main.rb (reading, preprocessing, and saving the data, generating the report)
- modify the main.rb driver script to accept the file paths (input, output, report) as parameters
- improve the report (this would require discussion with stakeholderes)
- revisit the transform_date method, current implementation is not elegant
