-- The function in this script is an SQL version for comparison
-- of performance with C version.

--

CREATE OR REPLACE FUNCTION jsonb_delete_left(a jsonb, b jsonb)
RETURNS jsonb AS
$BODY$
SELECT COALESCE(
(
SELECT ('{' || string_agg(to_json(key) || ':' || value, ',') || '}')
FROM jsonb_each(a)
WHERE NOT ('{' || to_json(key) || ':' || value || '}')::jsonb <@ b
)
, '{}')::jsonb;
$BODY$
LANGUAGE sql IMMUTABLE STRICT;

