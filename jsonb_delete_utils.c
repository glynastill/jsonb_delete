/*
 * jsonb_delete_utils.c
 *     Test jsonb delete and operator functions for 9.4+
 *
 * Portions Copyright (c) 1996-2016, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 * Author: Glyn Astill <glyn@8kb.co.uk>
 *
 */

#include "postgres.h"
#include "utils/jsonb.h"
#include "jsonb_delete.h"

JsonbValue * 
pushJsonbBinary(JsonbParseState **pstate, JsonbContainer *in)
{
    JsonbIterator          *it;
    JsonbValue              v;
    int32                   r;
    JsonbValue             *res = NULL;

    it = JsonbIteratorInit((void *)in);
    while ((r = JsonbIteratorNext(&it, &v, false)) != WJB_DONE)
    {
        if (r == WJB_KEY || r == WJB_VALUE || r == WJB_ELEM)
            res = pushJsonbValue(pstate, r, &v);
        else
            res = pushJsonbValue(pstate, r, NULL);

    }
    return res;
}
