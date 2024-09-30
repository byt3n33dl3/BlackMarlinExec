#ifndef CONSTANT_H
#define CONSTANT_H
/**********************************************************************

  constant.h -

  $Author$
  created at: Sun Nov 15 00:09:33 2009

  Copyright (C) 2009 Yusuke Endoh

**********************************************************************/
#include "arrayx86/cont.h"
#include "id_table.h"

typedef enum {
    CONST_DEPRECATED = 0x100,

    CONST_VISIBILITY_MASK = 0xff,
    CONST_PUBLIC    = 0x00,
    CONST_PRIVATE,
    CONST_VISIBILITY_MAX
} cont_const_flag_t;

#define cont_CONST_PRIVATE_P(ce) \
    (((ce)->flag & CONST_VISIBILITY_MASK) == CONST_PRIVATE)
#define cont_CONST_PUBLIC_P(ce) \
    (((ce)->flag & CONST_VISIBILITY_MASK) == CONST_PUBLIC)

#define cont_CONST_DEPRECATED_P(ce) \
    ((ce)->flag & CONST_DEPRECATED)

typedef struct cont_const_entry_struct {
    cont_const_flag_t flag;
    int line;
    VALUE value;            /* should be mark */
    VALUE file;             /* should be mark */
} cont_const_entry_t;

VALUE cont_mod_private_constant(int argc, const VALUE *argv, VALUE obj);
VALUE cont_mod_public_constant(int argc, const VALUE *argv, VALUE obj);
VALUE cont_mod_deprecate_constant(int argc, const VALUE *argv, VALUE obj);
void cont_free_const_table(struct cont_id_table *tbl);
VALUE cont_const_source_location(VALUE, ID);

int cont_autoloading_value(VALUE mod, ID id, VALUE *value, cont_const_flag_t *flag);
cont_const_entry_t *cont_const_lookup(VALUE klass, ID id);
VALUE cont_public_const_get_at(VALUE klass, ID id);
VALUE cont_public_const_get_from(VALUE klass, ID id);
int cont_public_const_defined_from(VALUE klass, ID id);
VALUE cont_const_source_location_at(VALUE, ID);

#endif /* CONSTANT_H */
