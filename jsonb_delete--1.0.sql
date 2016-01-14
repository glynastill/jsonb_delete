\echo Use "CREATE EXTENSION jsonb_delete" to load this file. \quit

CREATE OR REPLACE FUNCTION jsonb_delete(jsonb, jsonb) 
RETURNS jsonb
	AS 'MODULE_PATHNAME', 'jsonb_delete_jsonb'
LANGUAGE C IMMUTABLE STRICT;
COMMENT ON FUNCTION jsonb_delete(jsonb, jsonb) IS 'delete matching pairs in second argument from first argument';

DROP OPERATOR IF EXISTS - (jsonb, jsonb);
CREATE OPERATOR - ( PROCEDURE = jsonb_delete, LEFTARG = jsonb, RIGHTARG = jsonb);
COMMENT ON OPERATOR - (jsonb, jsonb) IS 'delete matching pairs from left operand';

