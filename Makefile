MODULE_big = jsonb_delete
DATA = jsonb_delete--1.0.sql
OBJS = jsonb_delete.o jsonb_delete_utils.o
DOCS = README.md

EXTENSION = jsonb_delete
REGRESS = jsonb_delete

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
