-- Given a player name prefix, this query retrieves all players whose names contain the given prefix in the first name or last name.
-- The pname contains first name and last name. Those names can potentially be hyphenated as well.
WITH split_names AS ( -- Create array of names from pname, splitting on spaces and hyphens
    SELECT pid, pname, regexp_split_to_array(lower(unaccent(replace(pname, '-', ' '))), '\s+') AS names
    FROM players
),
indexed_names AS ( -- For each array, generate rows for each index
    SELECT pid, pname, names, generate_subscripts(names, 1) AS name_index
    FROM split_names
),
names_search_terms AS ( -- Use indices to generate names for searching e.g. for Shai Gilgeous-Alexander, output Shai Gilgeous Alexander, Gilgeous Alexander, Alexander
  SELECT pid, pname, array_to_string(names[name_index:array_length(names, 1)], ' ') AS term
  FROM indexed_names
)
SELECT DISTINCT pid, pname
FROM players
WHERE EXISTS (
    SELECT 1
    FROM names_search_terms
    WHERE pid = players.pid
    AND term LIKE %s -- Match the user-inputted prefix against the generated search terms
);