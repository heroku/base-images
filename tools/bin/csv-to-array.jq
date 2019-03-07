  [
    split("\r\n")[]                  # transform csv input into array
  | split(",")                    # where first element has key names
  | select(length==2)              # and other elements have values
  ]
  | {h:["name", "version"], v:.[0:][]}            # {h:[keys], v:[values]}
  | [.h, .v]   # [ [keys], [values] ]
  | [ transpose[]                  # [ [key,value], [key,value], ... ]
      | {key:.[0], value:.[1]}     # [ {"key":key, "value":value}, ... ]
    ]
  | from_entries                   # { key:value, key:value, ... }
