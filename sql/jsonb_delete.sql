CREATE EXTENSION jsonb_delete VERSION '1.0';

-- jsonb deletion from an object should match on key/value
SELECT '{"a": 1, "b": 2, "c": 3}'::jsonb - '{"a": 4, "b": 2}'::jsonb;

-- jsonb deletion from an array should only match on element
SELECT '["a", "b", "c"]'::jsonb - '{"a": 4, "b": 2}'::jsonb;

-- jsonb deletion from nested objects should not be part matched
SELECT '{"a": 4, "b": 2, "c": 3, "d": {"a": 4}}'::jsonb - '{"a": 4, "b": 2}'::jsonb;

-- but a match of all nested values should
SELECT '{"a": 4, "b": 2, "c": 3, "d": {"a": 4}}'::jsonb - '{"d": {"a": 4}, "b": 2}'::jsonb;
SELECT '{"a":{"b":{"c":[1,[2,3,[4]],{"d":1}]}, "c":[1,2,3,4]}, "d":2}'::jsonb - '{"d":2}'::jsonb;

-- jsonb nulls are equal
SELECT '{"a": 1, "b": 2, "c": null}'::jsonb - '{"a": 4, "c": null}'::jsonb;

-- others
SELECT '{"a": 4, "b": 2, "c": 3, "d": {"a": false}}'::jsonb - '{"d": {"a": false}, "b": 2}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}}'::jsonb - '{"a": "test2", "c": {"a": false}, "b": 2.2}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test2", "b": 2.3, "c": {"a": true}, "d":false, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test", "b": 2.3, "c": {"a": true}, "d":false, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test2", "b": 2.2, "c": {"a": true}, "d":false, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test2", "b": 2.3, "c": {"a": false}, "d":false, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test2", "b": 2.3, "c": {"a": true}, "d":true, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test2", "b": 2.3, "c": {"a": true}, "d":false, "e":[1,"a",2]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test2", "b": 2.3, "c": {"a": true}, "d":false, "e":[1,2,"a"]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test", "b": 2.2, "c": {"a": true}, "d":false, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test", "b": 2.2, "c": {"a": false}, "d":false, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,3]}'::jsonb;
SELECT '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb - '{"a": "test", "b": 2.2, "c": {"a": false}, "d":true, "e":[1,2,"a"]}'::jsonb;
SELECT '["a",2,{"a":1, "b":2}]'::jsonb - '[[1]]'::jsonb;
SELECT '["a",2,{"a":1, "b":2}]'::jsonb - '[{"a":1}]'::jsonb;
SELECT '["a",2,{"a":1, "b":2}]'::jsonb - '[{"a":1, "b":2}]'::jsonb;
SELECT '["a",2,{"a":1, "b":2}]'::jsonb - '["a"]'::jsonb;
SELECT '["a",2,{"a":1, "b":2}]'::jsonb - '[2]'::jsonb;

