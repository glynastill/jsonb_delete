/* 
 * jsonb_delete.c 
 *     Test jsonb delete operator functions for 9.4+
 *
 * Portions Copyright (c) 1996-2016, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 * Author: Glyn Astill <glyn@8kb.co.uk>
 *
 */

#include "postgres.h"
#include "fmgr.h"
#include "utils/jsonb.h"
#include "utils/builtins.h"
#include "jsonb_delete.h"

#ifdef PG_MODULE_MAGIC
	PG_MODULE_MAGIC;
#endif 

Datum jsonb_delete_jsonb(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(jsonb_delete_jsonb);

/*
 * Operator function to delete top level keys and values from left operand 
 * where a match is found in the right operand.
 *
 * jsonb, jsonb -> jsonb
 *
 */
Datum 
jsonb_delete_jsonb(PG_FUNCTION_ARGS)
{
    Jsonb                  *jb1 = PG_GETARG_JSONB(0);
    Jsonb                  *jb2 = PG_GETARG_JSONB(1);
    JsonbValue             *res = NULL;
    JsonbParseState        *state = NULL;
    JsonbIterator          *it, *it2;
    JsonbValue              v, v2;
    JsonbValue              key;
    JsonbValue             *lookup = NULL;
    int32                   r, r2;
    bool                    push = true;

    /* check if right jsonb is empty and return left if so */
    if (JB_ROOT_COUNT(jb2) == 0)
        PG_RETURN_JSONB(jb1);

    it = JsonbIteratorInit(&jb1->root);

    while ((r = JsonbIteratorNext(&it, &v, true)) != WJB_DONE)
    {
        push = true;

        switch (r)
        {
            case WJB_BEGIN_ARRAY:
            case WJB_BEGIN_OBJECT:
            case WJB_END_ARRAY:
            case WJB_END_OBJECT:
                res = pushJsonbValue(&state, r, NULL);
                break;
            case WJB_ELEM:
                if (v.type == jbvBinary)
                {
                    it2 = JsonbIteratorInit(&jb2->root);
                    while ((r2 = JsonbIteratorNext(&it2, &v2, true)) != WJB_DONE)
                    {
                        if (v2.type == jbvBinary && v2.val.binary.len == v.val.binary.len &&
                            memcmp(v2.val.binary.data, v.val.binary.data, v2.val.binary.len) == 0)
                        {
                                push = false;
                                break;
                        }
                    }
                }
                else if (findJsonbValueFromContainer(&jb2->root, JB_FARRAY, &v) != NULL)
                    push = false;

                if (push) 
                {
                    if (v.type == jbvBinary) 
                        res = pushJsonbBinary(&state, v.val.binary.data);
                    else 
                        res = pushJsonbValue(&state, WJB_ELEM, &v);
                }
                break;
            case WJB_KEY:
                lookup = findJsonbValueFromContainer(&jb2->root, JB_FOBJECT, &v);

                key = v;
                r = JsonbIteratorNext(&it, &v, true);

                Assert(r == WJB_VALUE);

                if (lookup != NULL && lookup->type == v.type) 
                {
                    switch (lookup->type) 
                    {
                        /* Nulls within json are equal, but should not be equal to SQL nulls */
                        case jbvNull:
                            push = false;
                            break;
                        case jbvNumeric:
                            if (DatumGetBool(DirectFunctionCall2(numeric_eq, 
                                                                 PointerGetDatum(lookup->val.numeric), 
                                                                 PointerGetDatum(v.val.numeric))))
                                push = false;
                            break;
                        case jbvString:
                            if ((lookup->val.string.len == v.val.string.len) &&
                                (memcmp(lookup->val.string.val, 
                                        v.val.string.val, 
                                        lookup->val.string.len) == 0))
                                push = false;
                            break;
                        case jbvBinary:
                            if ((lookup->val.binary.len == v.val.binary.len) &&
                                (memcmp(lookup->val.binary.data, 
                                        v.val.binary.data, 
                                        lookup->val.binary.len) == 0))
                                push = false;
                                break;
                        case jbvBool:
                            if (lookup->val.boolean == v.val.boolean)
                                push = false;
                            break;
                        default:
                            ereport(ERROR, (errcode(ERRCODE_SUCCESSFUL_COMPLETION), errmsg("unrecognized lookup type: %d", (int) lookup->type)));
                        /* inner switch end */
                    }
                }

                if (push) 
                {                
                    res = pushJsonbValue(&state, WJB_KEY, &key);

                    /* if our value is nested binary data, iterate separately pushing each val */
                    if (v.type == jbvBinary) 
                        res = pushJsonbBinary(&state, v.val.binary.data);
                    else 
                        res = pushJsonbValue(&state, r, &v);
                }
                break;
            case WJB_VALUE:
                /* should not be possible */
            default:
                elog(ERROR, "impossible state: %d", r);
            /* switch end */ 
        }

    }

    if (JB_ROOT_IS_SCALAR(jb1) && !res->val.array.rawScalar && res->val.array.nElems == 1)
        res->val.array.rawScalar = true;

    PG_FREE_IF_COPY(jb1, 0); 
    PG_FREE_IF_COPY(jb2, 1); 

    PG_RETURN_JSONB(JsonbValueToJsonb(res));
}

