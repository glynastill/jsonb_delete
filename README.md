jsonb_delete
============

Provides simple deletion of matching key-value pairs at the top level of PostgreSQL jsonb types.

When the jsonb type was added in PostgreSQL 9.4 many modifying operators and functions were unimplemented, and although most operators have been <a href="https://wiki.postgresql.org/wiki/What's_new_in_PostgreSQL_9.5#JSONB-modifying_operators_and_functions">added</a> in PostgreSQL 9.5 there is still no quick way of getting the difference of two jsonb types at the top level.

* deletion using **-** operator
* jsonb_delete(jsonb, jsonb)

```sql
CREATE EXTENSION jsonb_delete;
``` 

Was originally part of <a href="https://github.com/glynastill/pg_jsonb_opx">this</a> repository, but as of PostgreSQL 9.5 there's equivalent functionality of the other parts available in core (For PostgreSQL 9.4 you can get the 9.5 functionality <a href="https://github.com/erthalion/jsonbx">here</a>).
